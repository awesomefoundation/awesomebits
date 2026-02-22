# frozen_string_literal: true

# PreScorer — deterministic text features computed before LLM scoring.
# Zero cost, runs locally on application text fields.

class PreScorer
  FIELDS = %w[about_me about_project use_for_money].freeze

  attr_reader :features

  def initialize(project)
    @project = project
    @features = {}
  end

  def analyze!
    @features = {}

    # Word counts per field
    FIELDS.each do |field|
      text = field_text(field)
      @features["word_count_#{field}"] = word_count(text)
    end
    @features["word_count_total"] = FIELDS.sum { |f| @features["word_count_#{f}"] }

    # Field length variance (low = suspicious uniformity, AI template signal)
    counts = FIELDS.map { |f| @features["word_count_#{f}"].to_f }
    @features["field_length_variance"] = variance(counts).round(2)

    # Sentence-level stats (AI tends toward uniform sentence length)
    all_text = combined_text
    sentences = all_text.split(/[.!?]+/).map(&:strip).reject(&:empty?)
    lengths = sentences.map { |s| s.split(/\s+/).length }
    @features["sentence_count"] = sentences.length
    @features["avg_sentence_length"] = lengths.empty? ? 0.0 : (lengths.sum.to_f / lengths.length).round(1)
    @features["sentence_length_variance"] = variance(lengths.map(&:to_f)).round(2)

    # Punctuation signals
    @features["exclamation_count"] = all_text.count("!")
    @features["question_mark_count"] = all_text.count("?")

    # Content signals
    @features["url_count"] = all_text.scan(%r{https?://\S+}).length
    @features["dollar_sign_count"] = all_text.count("$")
    @features["number_count"] = all_text.scan(/\b\d[\d,.]*\b/).length
    @features["email_count"] = all_text.scan(/\S+@\S+\.\S+/).length

    # Capitalized words (proxy for proper nouns / named entities)
    words = all_text.split(/\s+/)
    # Skip first word of each sentence
    mid_sentence_caps = words.each_cons(2).count { |prev, word|
      !prev.match?(/[.!?]\z/) && word.match?(/\A[A-Z][a-z]/)
    }
    @features["capitalized_word_count"] = mid_sentence_caps
    @features["capitalized_word_density"] = if words.length > 10
      (mid_sentence_caps.to_f / words.length * 100).round(1)
    else
      0.0
    end

    # Empty field detection
    @features["empty_field_count"] = FIELDS.count { |f| field_text(f).strip.empty? }

    # Has images (title/about fields mention image/photo/picture URLs)
    @features["has_image_reference"] = all_text.match?(/\.(jpg|jpeg|png|gif|webp|bmp)/i) ? 1 : 0

    @features
  end

  private

  def field_text(name)
    @project[name].to_s
  end

  def combined_text
    FIELDS.map { |f| field_text(f).strip }.reject(&:empty?).join(" ")
  end

  def word_count(text)
    text.strip.empty? ? 0 : text.strip.split(/\s+/).length
  end

  def variance(values)
    return 0.0 if values.length < 2
    mean = values.sum / values.length.to_f
    values.sum { |v| (v - mean)**2 } / values.length.to_f
  end
end
