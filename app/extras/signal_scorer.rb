# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

# SignalScorer — AI-assisted grant application pre-screening.
#
# Two-layer pipeline:
#   1. PreScorer: deterministic text features (zero cost, local)
#   2. LLM Scorer: Anthropic API with Trust Equation rubric
#
# Usage:
#   scorer = SignalScorer.new(project)
#   result = scorer.score!       # full pipeline: pre-score + LLM
#   scorer.composite_score       # 0.0-1.0
#   scorer.reason                # one-sentence explanation
#   scorer.primary_category      # "public-art"
#   scorer.tags                  # ["mentorship", "emerging-artists"]
#
# The result is persisted to project.metadata["signal_score"].
#
class SignalScorer
  ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages"
  DEFAULT_MODEL = "claude-haiku-4-5-20251001"
  MAX_TOKENS = 1024

  attr_reader :project, :score_result

  class ScoringError < StandardError; end

  def initialize(project, api_key: nil)
    @project = project
    @api_key = api_key || ENV["ANTHROPIC_API_KEY"]
    @config = SignalScoreConfig.resolve(project.chapter) rescue {}
  end

  # Full scoring pipeline: LLM score + persist to metadata.
  def score!
    raise ScoringError, "No Anthropic API key configured" unless @api_key.present?

    # Build the prompt
    application_text = format_application
    system_prompt = build_system_prompt

    # Call Anthropic Messages API with tool_use for structured output
    response = call_anthropic(
      system: system_prompt,
      messages: [{ "role" => "user", "content" => "Score this grant application:\n\n#{application_text}" }],
      tools: [score_tool],
      tool_choice: { "type" => "tool", "name" => "score_application" }
    )

    # Extract tool result
    tool_block = response.dig("content")&.find { |c| c["type"] == "tool_use" }
    raise ScoringError, "No tool_use block in response" unless tool_block

    @score_result = tool_block["input"]

    # Persist to metadata
    persist_score!

    @score_result
  end

  def composite_score
    score_result&.dig("composite_score")
  end

  def reason
    score_result&.dig("reason")
  end

  def flags
    score_result&.dig("flags") || []
  end

  def features
    score_result&.dig("features") || {}
  end

  def primary_category
    (project.metadata.dig("signal_score", "primary_category") rescue nil) ||
      score_result&.dig("primary_category")
  end

  def tags
    (project.metadata.dig("signal_score", "tags") rescue nil) ||
      score_result&.dig("tags") || []
  end

  # Score color for UI badge
  def score_color
    s = composite_score
    return "gray" unless s
    case s
    when 0.7..1.0 then "green"
    when 0.5...0.7 then "yellow"
    when 0.3...0.5 then "orange"
    else "red"
    end
  end

  # Human-readable score label
  def score_label
    s = composite_score
    return "Unscored" unless s
    case s
    when 0.7..1.0 then "Strong"
    when 0.5...0.7 then "Solid"
    when 0.3...0.5 then "Borderline"
    when 0.1...0.3 then "Weak"
    else "Low Signal"
    end
  end

  private

  def format_application
    parts = []
    parts << "Title: #{project.title}" if project.title.present?
    parts << "About Me: #{project.about_me}" if project.about_me.present?
    parts << "About Project: #{project.about_project}" if project.about_project.present?
    parts << "Use for Money: #{project.use_for_money}" if project.use_for_money.present?
    parts << "URL: #{project.url}" if project.url.present?

    # Include extra answers if present
    (1..3).each do |i|
      q = project.send("extra_question_#{i}") rescue nil
      a = project.send("extra_answer_#{i}") rescue nil
      if q.present? && a.present?
        parts << "#{q}: #{a}"
      end
    end

    parts.join("\n\n")
  end

  def build_system_prompt
    # Use PromptBuilder if available (scripts), otherwise inline
    if defined?(PromptBuilder)
      builder = PromptBuilder.new(chapter: project.chapter&.name)
      builder.system_prompt
    else
      default_system_prompt
    end
  end

  def score_tool
    if defined?(PromptBuilder)
      PromptBuilder::SCORE_TOOL
    else
      {
        "name" => "score_application",
        "description" => "Score a grant application and extract structured features",
        "input_schema" => {
          "type" => "object",
          "required" => %w[composite_score reason flags features],
          "properties" => {
            "composite_score" => { "type" => "number", "description" => "Overall score 0.0-1.0" },
            "reason" => { "type" => "string", "description" => "One-sentence explanation" },
            "flags" => { "type" => "array", "items" => { "type" => "string" } },
            "features" => {
              "type" => "object",
              "required" => %w[credibility reliability intimacy self_interest specificity creativity budget_alignment catalytic_potential community_benefit personal_voice ai_spam_likelihood ai_writing_likelihood],
              "properties" => %w[credibility reliability intimacy self_interest specificity creativity budget_alignment catalytic_potential community_benefit personal_voice ai_spam_likelihood ai_writing_likelihood].each_with_object({}) { |k, h| h[k] = { "type" => "number" } },
            },
          },
        },
      }
    end
  end

  def call_anthropic(system:, messages:, tools:, tool_choice:)
    uri = URI(ANTHROPIC_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 30

    model = @config.dig("scoring_config", "model") || DEFAULT_MODEL

    body = {
      "model" => model,
      "max_tokens" => MAX_TOKENS,
      "system" => system,
      "messages" => messages,
      "tools" => tools,
      "tool_choice" => tool_choice,
    }

    request = Net::HTTP::Post.new(uri.path)
    request["Content-Type"] = "application/json"
    request["x-api-key"] = @api_key
    request["anthropic-version"] = "2023-06-01"
    request.body = body.to_json

    response = http.request(request)

    unless response.code.to_i == 200
      raise ScoringError, "Anthropic API error #{response.code}: #{response.body[0..200]}"
    end

    JSON.parse(response.body)
  end

  def persist_score!
    return unless @score_result

    metadata = project.metadata || {}
    metadata["signal_score"] = @score_result.merge(
      "scored_at" => Time.current.iso8601,
      "model" => @config.dig("scoring_config", "model") || DEFAULT_MODEL,
      "variant" => "live"
    )
    project.update_column(:metadata, metadata)
  end

  def default_system_prompt
    <<~PROMPT
      You are an expert grant application screener for the Awesome Foundation.

      The Awesome Foundation is a global network of volunteer "micro-trustees" who each chip in to award $1,000 grants for awesome projects. No strings attached — the money goes to creative, community-benefiting, unique ideas.

      Score each application using the score_application tool. Extract structured features to help trustees prioritize their review.

      ## Scoring Rubric (composite_score: 0.0 to 1.0)
      - 0.0-0.1: Clear spam, gibberish, test submissions
      - 0.1-0.3: Real but very weak — business pitches, personal fundraising, vague ideas
      - 0.3-0.5: Borderline — decent concept but missing details, unclear community benefit
      - 0.5-0.7: Solid — clear project, community benefit, actionable plan
      - 0.7-0.9: Strong — creative, specific, well-articulated, exactly what AF funds
      - 0.9-1.0: Exceptional — innovative, clearly impactful, inspiring

      ## Feature Dimensions (Trust Equation: T = (C + R + I) / (1 + S))
      Numerator (higher = better):
      - credibility: Clear budget, realistic plan, relevant expertise (0-1)
      - reliability: Track record, prior work, organizational backing (0-1)
      - intimacy: Connection to community, local ties, authentic voice (0-1)
      Denominator (higher = worse):
      - self_interest: Money primarily benefits applicant? (0-1)
      Additional:
      - specificity, creativity, budget_alignment, catalytic_potential, community_benefit, personal_voice (all 0-1)
      - ai_spam_likelihood: Mass-generated? (0-1)
      - ai_writing_likelihood: AI writing patterns? INFORMATIONAL ONLY (0-1)

      ## Flags: spam, ai_spam, duplicate, incomplete, wrong_location, business_pitch, personal_fundraising, low_effort

      ## Key Principles
      - AF values creativity, community impact, and fun
      - $1,000 is small — projects should be scoped appropriately
      - "Too weird for traditional funders" = MORE awesome, not less
      - ~28% of applications are typically review-worthy
    PROMPT
  end
end
