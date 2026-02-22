#!/usr/bin/env ruby
# frozen_string_literal: true

# score_grants.rb — Signal Score batch scoring via Anthropic API
#
# Usage:
#   ruby scripts/signal-score/score_grants.rb build-sample --count 400
#   ruby scripts/signal-score/score_grants.rb build-batch [--model claude-haiku-4-5-20251001]
#   ruby scripts/signal-score/score_grants.rb submit --input .scratch/data/batch-haiku.jsonl
#   ruby scripts/signal-score/score_grants.rb results --batch-id <id>
#   ruby scripts/signal-score/score_grants.rb pre-score  # Run PreScorer on sample
#
# Requires: ANTHROPIC_API_KEY in .env.local

require "json"
require "net/http"
require "uri"
require "fileutils"
require_relative "pre_scorer"
require_relative "prompt_builder"
require_relative "anthropic_cache"

DATA_DIR = File.expand_path("../../.scratch/data", __dir__)
DB_PATH = File.join(DATA_DIR, "awesomebits.duckdb")

MODELS = {
  "haiku" => "claude-haiku-4-5-20251001",
  "sonnet" => "claude-sonnet-4-20250514",
  "opus" => "claude-opus-4-0-20250514",
}.freeze

CACHE = AnthropicCache.new

# --- DuckDB helper ---

def duckdb(sql)
  result = `duckdb #{DB_PATH} -json -c #{Shellwords.escape(sql)} 2>&1`
  raise "DuckDB error: #{result}" unless $?.success?
  JSON.parse(result.empty? ? "[]" : result)
end

# --- Tool schema for structured output ---

# --- Prompt builder instance ---

def prompt_builder(chapter: nil)
  PromptBuilder.new(chapter: chapter)
end

def build_user_message(builder, project, examples_text = nil)
  app_text = builder.format_application(project)
  if examples_text
    "Here are examples of previously funded and hidden applications:\n\n#{examples_text}\n\n---\n\nNow score this application:\n\n#{app_text}"
  else
    "Score this application:\n\n#{app_text}"
  end
end

def build_few_shot_examples(builder)
  labeled = duckdb(<<~SQL)
    SELECT cv.*, c.name as chapter_name
    FROM chicago_validation cv
    LEFT JOIN chapters c ON cv.chapter_id = c.id
    ORDER BY actual_label, hidden_reason
  SQL

  funded = labeled.select { |p| p["actual_label"] == "funded" }
  hidden = labeled.select { |p| p["actual_label"] == "hidden" }

  builder.few_shot_text(funded, hidden)
end

# --- Commands ---

def cmd_build_sample(count:)
  puts "Building stratified sample of #{count} Chicago apps..."

  labeled = duckdb("SELECT count(*) as n FROM chicago_validation")[0]["n"]
  unlabeled_needed = count - labeled
  puts "  #{labeled} labeled + #{unlabeled_needed} unlabeled needed"

  # Stratified by year
  years = duckdb(<<~SQL)
    SELECT extract(year from p.created_at::date) as yr, count(*) as n
    FROM projects p JOIN chapters c ON p.chapter_id = c.id
    WHERE c.name = 'Chicago, IL'
      AND p.funded_on IS NULL AND p.hidden_at IS NULL
    GROUP BY 1 ORDER BY 1
  SQL

  total_unlabeled = years.sum { |y| y["n"] }
  sample_ids = []

  years.each do |y|
    yr_count = [(y["n"].to_f / total_unlabeled * unlabeled_needed).round, y["n"]].min
    next if yr_count == 0

    ids = duckdb(<<~SQL)
      SELECT p.id FROM projects p JOIN chapters c ON p.chapter_id = c.id
      WHERE c.name = 'Chicago, IL'
        AND p.funded_on IS NULL AND p.hidden_at IS NULL
        AND extract(year from p.created_at::date) = #{y['yr']}
      ORDER BY random()
      LIMIT #{yr_count}
    SQL
    sample_ids += ids.map { |r| r["id"] }
    puts "  #{y['yr']}: #{yr_count}/#{y['n']} unlabeled"
  end

  # Build the full sample: labeled + unlabeled
  sql = <<~SQL
    CREATE OR REPLACE TABLE sample_400 AS
    SELECT p.*, c.name as chapter_name,
      CASE
        WHEN p.funded_on IS NOT NULL THEN 'funded'
        WHEN p.hidden_at IS NOT NULL THEN 'hidden'
        ELSE 'unlabeled'
      END as actual_label
    FROM projects p
    LEFT JOIN chapters c ON p.chapter_id = c.id
    WHERE p.id IN (
      SELECT id FROM chicago_validation
      UNION ALL
      SELECT unnest([#{sample_ids.join(",")}])
    )
  SQL
  duckdb(sql)

  result = duckdb("SELECT actual_label, count(*) as n FROM sample_400 GROUP BY 1 ORDER BY 1")
  result.each { |r| puts "  #{r['actual_label']}: #{r['n']}" }

  total = duckdb("SELECT count(*) as n FROM sample_400")[0]["n"]
  puts "\nSample: #{total} apps saved to sample_400 table"

  # Export to parquet
  duckdb("COPY sample_400 TO '#{DATA_DIR}/sample_400.parquet' (FORMAT PARQUET)")
  puts "Exported to #{DATA_DIR}/sample_400.parquet"
end

def cmd_pre_score
  puts "Running PreScorer on sample_400..."

  projects = duckdb("SELECT * FROM sample_400")
  results = {}

  projects.each do |p|
    scorer = PreScorer.new(p)
    scorer.analyze!
    results[p["id"]] = scorer.features
  end

  output = File.join(DATA_DIR, "pre_scores.json")
  File.write(output, JSON.pretty_generate(results))
  puts "Wrote #{results.length} pre-scores to #{output}"

  # Summary stats
  totals = results.values.map { |f| f["word_count_total"] }
  puts "\nWord count stats:"
  puts "  Min: #{totals.min}, Max: #{totals.max}, Avg: #{(totals.sum.to_f / totals.length).round(0)}"
  puts "  Median: #{totals.sort[totals.length / 2]}"

  empty = results.values.count { |f| f["empty_field_count"] > 0 }
  puts "  Apps with empty fields: #{empty}/#{results.length}"
end

def cmd_build_batch(model_alias:, chapter: nil, no_fewshot: false)
  builder = prompt_builder(chapter: chapter)
  model = MODELS[model_alias] || model_alias
  puts "Building batch for model: #{model} (#{model_alias})"
  puts "  Chapter: #{chapter || 'default'}, few-shot: #{!no_fewshot}"

  examples_text = no_fewshot ? nil : build_few_shot_examples(builder)
  projects = duckdb("SELECT * FROM sample_400")
  puts "  #{projects.length} projects to score"

  # Skip cached requests
  skipped = 0
  lines = []
  projects.each do |p|
    request_params = {
      model: model,
      system: builder.system_prompt,
      tools: [builder.score_tool],
      messages: [{ role: "user", content: build_user_message(builder, p, examples_text) }],
    }

    if CACHE.cached?(request_params)
      skipped += 1
      next
    end

    lines << {
      custom_id: "project-#{p['id']}",
      params: {
        model: model,
        max_tokens: 1024,
        system: builder.system_prompt,
        tools: [builder.score_tool],
        tool_choice: { type: "tool", name: "score_application" },
        messages: [{ role: "user", content: build_user_message(builder, p, examples_text) }],
      },
    }.to_json
  end
  puts "  Skipped #{skipped} cached requests" if skipped > 0

  output = File.join(DATA_DIR, "batch-#{model_alias}.jsonl")
  File.write(output, lines.join("\n") + "\n")
  puts "Wrote #{lines.length} requests to #{output}"

  # Cost estimate
  total_chars = lines.sum(&:length)
  input_tokens = total_chars / 4
  case model_alias
  when "haiku"
    cost = (input_tokens / 1_000_000.0 * 0.80 + projects.length * 200 / 1_000_000.0 * 4.0) * 0.5
  when "sonnet"
    cost = (input_tokens / 1_000_000.0 * 3.0 + projects.length * 200 / 1_000_000.0 * 15.0) * 0.5
  when "opus"
    cost = (input_tokens / 1_000_000.0 * 15.0 + projects.length * 200 / 1_000_000.0 * 75.0) * 0.5
  end
  puts "Estimated batch cost (50% discount): ~$#{'%.2f' % cost}" if cost
end

def cmd_submit(input:)
  api_key = ENV["ANTHROPIC_API_KEY"]
  raise "ANTHROPIC_API_KEY not set — add to .env.local" unless api_key

  requests = File.readlines(input).map { |l| JSON.parse(l) }
  puts "Submitting #{requests.length} requests to Anthropic Batch API..."

  uri = URI("https://api.anthropic.com/v1/messages/batches")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  req = Net::HTTP::Post.new(uri)
  req["x-api-key"] = api_key
  req["anthropic-version"] = "2023-06-01"
  req["anthropic-beta"] = "message-batches-2024-09-24"
  req["content-type"] = "application/json"
  req.body = { requests: requests }.to_json

  resp = http.request(req)
  unless resp.is_a?(Net::HTTPSuccess)
    warn "Error #{resp.code}: #{resp.body}"
    exit 1
  end

  result = JSON.parse(resp.body)
  puts "Batch created: #{result['id']}"
  puts "Status: #{result['processing_status']}"

  # Save batch ID
  id_file = input.sub(".jsonl", "-batch-id.txt")
  File.write(id_file, result["id"] + "\n")
  puts "Batch ID saved to #{id_file}"
  result["id"]
end

def cmd_results(batch_id:, output: nil)
  api_key = ENV["ANTHROPIC_API_KEY"]
  raise "ANTHROPIC_API_KEY not set" unless api_key

  headers = {
    "x-api-key" => api_key,
    "anthropic-version" => "2023-06-01",
    "anthropic-beta" => "message-batches-2024-09-24",
  }

  # Check status
  uri = URI("https://api.anthropic.com/v1/messages/batches/#{batch_id}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Get.new(uri, headers)
  resp = http.request(req)
  status = JSON.parse(resp.body)

  puts "Status: #{status['processing_status']}"
  counts = status["request_counts"] || {}
  puts "Progress: #{counts['succeeded']}/#{counts['processing']} succeeded"

  unless status["processing_status"] == "ended"
    puts "Batch still processing. Try again later."
    return
  end

  # Fetch results
  uri = URI("https://api.anthropic.com/v1/messages/batches/#{batch_id}/results")
  req = Net::HTTP::Get.new(uri, headers)
  resp = http.request(req)

  scores = {}
  resp.body.strip.split("\n").each do |line|
    item = JSON.parse(line)
    project_id = item["custom_id"].sub("project-", "").to_i
    begin
      # With tool_use, result is in tool call input
      tool_call = item.dig("result", "message", "content")&.find { |c| c["type"] == "tool_use" }
      if tool_call
        parsed = tool_call["input"]
      else
        # Fallback: try text content
        text = item.dig("result", "message", "content", 0, "text") || ""
        json_match = text.match(/\{[\s\S]*\}/)
        parsed = json_match ? JSON.parse(json_match[0]) : nil
      end
      scores[project_id] = parsed.merge("project_id" => project_id) if parsed
    rescue => e
      warn "Failed to parse result for project-#{project_id}: #{e.message}"
    end
  end

  output ||= File.join(DATA_DIR, "scores-#{batch_id[0..12]}.json")
  File.write(output, JSON.pretty_generate(scores))
  puts "\nWrote #{scores.length} scores to #{output}"

  # Summary
  score_values = scores.values.map { |s| s["composite_score"] }.compact
  avg = score_values.sum / score_values.length.to_f
  low = score_values.count { |s| s <= 0.3 }
  mid = score_values.count { |s| s > 0.3 && s <= 0.7 }
  high = score_values.count { |s| s > 0.7 }
  puts "\nScore distribution:"
  puts "  Low (≤0.3):    #{low} apps"
  puts "  Mid (0.3-0.7): #{mid} apps"
  puts "  High (>0.7):   #{high} apps"
  puts "  Average:        #{'%.3f' % avg}"
end

# --- CLI ---

require "shellwords"

command = ARGV.shift

# Load .env.local if present
env_file = File.expand_path("../../.env.local", __dir__)
if File.exist?(env_file)
  File.readlines(env_file, encoding: "UTF-8").each do |line|
    line = line.strip
    next if line.empty? || line.start_with?("#")
    key, value = line.split("=", 2)
    ENV[key] = value if key && value
  end
end

case command
when "build-sample"
  i = ARGV.index("--count")
  count = i ? ARGV[i + 1].to_i : 400
  cmd_build_sample(count: count)

when "pre-score"
  cmd_pre_score

when "build-batch"
  i = ARGV.index("--model")
  model = i ? ARGV[i + 1] : "haiku"
  i = ARGV.index("--chapter")
  chapter = i ? ARGV[i + 1] : nil
  no_fewshot = ARGV.include?("--no-fewshot")
  cmd_build_batch(model_alias: model, chapter: chapter, no_fewshot: no_fewshot)

when "submit"
  i = ARGV.index("--input")
  input = i ? ARGV[i + 1] : nil
  raise "--input required" unless input
  cmd_submit(input: input)

when "results"
  i = ARGV.index("--batch-id")
  batch_id = i ? ARGV[i + 1] : nil
  raise "--batch-id required" unless batch_id
  cmd_results(batch_id: batch_id)

when "submit-all"
  %w[haiku sonnet opus].each do |m|
    input = File.join(DATA_DIR, "batch-#{m}.jsonl")
    next unless File.exist?(input)
    puts "\n=== Submitting #{m} ==="
    cmd_submit(input: input)
  end

else
  puts <<~USAGE
    Usage: ruby scripts/signal-score/score_grants.rb <command>

    Commands:
      build-sample   Build stratified 400-app sample in DuckDB
      pre-score      Run PreScorer on sample (deterministic features)
      build-batch    Build batch JSONL [--model haiku|sonnet|opus] [--chapter name] [--no-fewshot]
      submit         Submit batch [--input path.jsonl]
      submit-all     Submit all built batches (haiku, sonnet, opus)
      results        Fetch results [--batch-id <id>]
  USAGE
end
