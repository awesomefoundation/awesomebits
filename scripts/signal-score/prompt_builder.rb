# frozen_string_literal: true

require "json"

# Assembles scoring prompts with chapter-specific config overrides.
#
# Config resolution order:
#   1. Chapter-specific overrides (from DB or .scratch/prompts/{slug}.json)
#   2. Global default (.scratch/prompts/default.json or hardcoded)
#
# Usage:
#   builder = PromptBuilder.new(chapter: "Chicago, IL")
#   system_prompt = builder.system_prompt
#   tool_schema = builder.score_tool
#   few_shot = builder.few_shot_text(funded_projects, hidden_projects)
#
class PromptBuilder
  CATEGORIES_PATH = File.expand_path("../../config/signal_score/categories.json", __dir__)
  PROMPTS_DIR = File.expand_path("../../.scratch/prompts", __dir__)

  attr_reader :config

  def initialize(chapter: nil, config_override: nil)
    @config = resolve_config(chapter, config_override)
  end

  # --- Prompt assembly ---

  def system_prompt
    # Full override takes precedence
    return @config["system_prompt"] if @config["system_prompt"]

    base = default_system_prompt
    addendum = @config["rubric_addendum"]
    addendum ? "#{base}\n\n#{addendum}" : base
  end

  def score_tool
    SCORE_TOOL
  end

  def category_tool
    CATEGORY_TOOL
  end

  def categories
    @categories ||= begin
      custom = @config.dig("category_config", "custom") || []
      disabled = @config.dig("category_config", "disabled") || []
      base = canonical_categories.reject { |c| disabled.include?(c["slug"]) }
      base + custom
    end
  end

  def category_slugs
    categories.map { |c| c["slug"] }
  end

  def model
    @config["model"] || "claude-haiku-4-5-20251001"
  end

  def grant_amount
    @config["grant_amount"] || 1000
  end

  def currency
    @config["currency"] || "USD"
  end

  def few_shot_count
    @config["few_shot_count"] || 15
  end

  # Build the few-shot examples text block.
  def few_shot_text(funded_projects, hidden_projects)
    n = few_shot_count

    text = "## EXAMPLES OF FUNDED (WINNING) APPLICATIONS\n\n"
    funded_projects.first(n).each do |p|
      text += "### Project #{p['id']} — FUNDED\n#{format_application(p)}\n\n"
    end

    text += "## EXAMPLES OF HIDDEN (REJECTED/FILTERED) APPLICATIONS\n\n"
    hidden_projects.first(n).each do |p|
      reason = p["hidden_reason"] ? " (reason: #{p['hidden_reason']})" : ""
      text += "### Project #{p['id']} — HIDDEN#{reason}\n#{format_application(p)}\n\n"
    end

    text
  end

  def format_application(project)
    parts = ["Title: #{project['title'] || '(empty)'}"]
    parts << "Chapter: #{project['chapter_name']}" if project["chapter_name"]
    %w[about_me about_project use_for_money].each do |f|
      val = project[f].to_s.strip
      parts << "#{f.tr('_', ' ').split.map(&:capitalize).join(' ')}: #{val}" unless val.empty?
    end
    parts.join("\n")
  end

  private

  def resolve_config(chapter, override)
    base = load_default_config
    if chapter
      chapter_config = load_chapter_config(chapter)
      base = deep_merge(base, chapter_config) if chapter_config
    end
    base = deep_merge(base, override) if override
    base
  end

  def load_default_config
    path = File.join(PROMPTS_DIR, "default.json")
    File.exist?(path) ? JSON.parse(File.read(path)) : {}
  end

  def load_chapter_config(chapter)
    slug = chapter.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/-+$/, "")
    path = File.join(PROMPTS_DIR, "chapters", "#{slug}.json")
    File.exist?(path) ? JSON.parse(File.read(path)) : nil
  end

  def canonical_categories
    @canonical_categories ||= JSON.parse(File.read(CATEGORIES_PATH))
  end

  def deep_merge(base, overlay)
    base.merge(overlay) do |_key, old_val, new_val|
      if old_val.is_a?(Hash) && new_val.is_a?(Hash)
        deep_merge(old_val, new_val)
      else
        new_val
      end
    end
  end

  # --- Default system prompt (hardcoded fallback) ---

  def default_system_prompt
    amount = grant_amount
    curr = currency == "USD" ? "$" : currency

    <<~PROMPT
      You are an expert grant application screener for the Awesome Foundation.

      The Awesome Foundation is a global network of volunteer "micro-trustees" who each chip in to award #{curr}#{amount} grants for awesome projects. No strings attached — the money goes to creative, community-benefiting, unique ideas.

      Score each application using the score_application tool. Extract structured features to help trustees prioritize their review.

      ## Scoring Rubric (composite_score: 0.0 to 1.0)

      - 0.0–0.1: Clear spam, gibberish, test submissions, or AI-generated mass submissions
      - 0.1–0.3: Real but very weak — business pitches, personal fundraising, vague ideas, wrong location
      - 0.3–0.5: Borderline — decent concept but missing details, unclear community benefit, generic
      - 0.5–0.7: Solid — clear project, community benefit, actionable plan, reasonable for #{curr}#{amount}
      - 0.7–0.9: Strong — creative, specific, well-articulated, exactly what AF funds
      - 0.9–1.0: Exceptional — innovative, clearly impactful, inspiring, would excite any trustee

      ## Feature Dimensions

      ### Trust Equation: T = (Credibility + Reliability + Intimacy) / (1 + Self-Interest)

      **Numerator (higher = better):**
      - credibility: Clear budget, realistic plan, relevant expertise. (0=vague, 1=detailed budget + clear execution)
      - reliability: Track record, prior work, organizational backing. (0=no evidence, 1=strong track record)
      - intimacy: Connection to community, local ties, authentic voice. Named neighborhoods, specific orgs, personal anecdotes. Sub-city precision (ward/zip) scores higher than city-level. (0=generic, 1=deeply embedded)

      **Denominator (higher = worse):**
      - self_interest: Money primarily benefits applicant? Living expenses, tuition, business startup, self-payment >50% of budget. (0=community-benefiting, 1=self-serving)

      ### Additional Signals

      - specificity: Concrete details — costs, addresses, timelines, partner names. (0=vague, 1=highly specific)
      - creativity: How original, unique, fun, or surprising? "The opposite of whimsy is boring, not serious." (0=generic, 1=delightfully novel)
      - budget_alignment: Can #{curr}#{amount} meaningfully complete this? Is it a "drop in the bucket" or perfectly sized? (0=wildly mismatched, 1=perfectly scoped)
      - catalytic_potential: Does #{curr}#{amount} unlock something bigger — prototype, proof-of-concept, career catalyst? (0=standalone purchase, 1=unlocks outsized outcomes)
      - community_benefit: Clear benefit beyond the applicant? Creating new connections scores higher than serving existing community. (0=purely personal, 1=broad community impact + new connections)
      - personal_voice: Does it sound like a real person? Quirky details, informal language, personal anecdotes = POSITIVE. Over-polished corporate language = NEGATIVE. (0=robotic/templated, 1=authentic and personal)

      ### AI Detection (two separate signals)

      - ai_spam_likelihood: Mass-generated generic proposal — no personal details, no local knowledge. (0=clearly genuine, 1=almost certainly mass-generated)
      - ai_writing_likelihood: Exhibits AI writing patterns? Uniform sentences, significance inflation, promotional language. INFORMATIONAL ONLY — do not factor into composite_score. (0=clearly human, 1=heavily AI-styled)

      ## Flags (include any that apply)
      spam, ai_spam, duplicate, incomplete, wrong_location, business_pitch, personal_fundraising, low_effort

      ## Key Principles
      - AF values creativity, community impact, and fun
      - #{curr}#{amount} is small — projects should be scoped appropriately
      - Professional credentials are neutral-to-negative
      - Projects "too weird for traditional funders" = MORE awesome, not less
      - ~28% of applications are typically review-worthy
    PROMPT
  end

  # --- Tool schemas ---

  SCORE_TOOL = {
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
          "required" => %w[
            credibility reliability intimacy self_interest
            specificity creativity budget_alignment catalytic_potential
            community_benefit personal_voice
            ai_spam_likelihood ai_writing_likelihood
          ],
          "properties" => %w[
            credibility reliability intimacy self_interest
            specificity creativity budget_alignment catalytic_potential
            community_benefit personal_voice
            ai_spam_likelihood ai_writing_likelihood
          ].each_with_object({}) { |k, h| h[k] = { "type" => "number" } },
        },
      },
    },
  }.freeze

  def self.build_category_tool
    cats = JSON.parse(File.read(CATEGORIES_PATH))
    {
      "name" => "categorize_application",
      "description" => "Categorize a grant application with thematic scores and freeform tags",
      "input_schema" => {
        "type" => "object",
        "required" => %w[categories tags primary_category],
        "properties" => {
          "primary_category" => { "type" => "string", "description" => "The single most fitting category slug" },
          "categories" => {
            "type" => "object",
            "description" => "Confidence score 0-1 for each category (omit below 0.2)",
            "properties" => cats.each_with_object({}) { |c, h|
              h[c["slug"]] = { "type" => "number", "description" => c["description"] }
            },
          },
          "tags" => {
            "type" => "array",
            "items" => { "type" => "string" },
            "description" => "3-5 freeform keyword tags for themes not in canonical categories",
          },
        },
      },
    }.freeze
  end

  CATEGORY_TOOL = build_category_tool
end
