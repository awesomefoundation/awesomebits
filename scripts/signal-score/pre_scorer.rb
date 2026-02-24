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
    @features["number_count"] = all_text.scan(/\b\d[\d,.]*\b/).length
    @features["email_count"] = all_text.scan(/\S+@\S+\.\S+/).length

    # Money extraction (international currencies)
    money_matches = extract_money_mentions(all_text)
    @features["money_mention_count"] = money_matches.length

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

    # TF-IDF features (requires static IDF table)
    if self.class.idf_table
      tfidf_scores = compute_tfidf(all_text)
      @features["tfidf_mean"] = tfidf_scores.empty? ? 0.0 : (tfidf_scores.values.sum / tfidf_scores.length.to_f).round(4)
      @features["tfidf_max"] = tfidf_scores.empty? ? 0.0 : tfidf_scores.values.max.round(4)
      @features["tfidf_unique_terms"] = tfidf_scores.count { |_, v| v > 0 }
    end

    @features
  end

  # Load static IDF table (computed from full corpus via notebook 02)
  def self.idf_table
    @idf_table
  end

  def self.load_idf(path)
    require "json"
    @idf_table = JSON.parse(File.read(path))
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

  # International money/currency extraction
  CURRENCY_SYMBOLS = /[\$\£\€\¥\₹\₩\₫\₱\₺\₽\฿]/
  CURRENCY_PREFIXED = /(?:A|NZ|CA|HK|S|US|C)\$/
  CURRENCY_CODES = /\b(?:USD|GBP|EUR|AUD|NZD|CAD|CHF|JPY|CNY|INR|BRL|MXN|ZAR|SEK|NOK|DKK|KRW|SGD|HKD|TWD|THB|MYR|PHP|IDR|VND|CZK|PLN|HUF|RON|RUB|TRY|ILS|AED|SAR|CLP|COP|PEN|ARS)\b/i
  CURRENCY_WORDS = /\b(?:dollars?|pounds?|euros?|yen|yuan|rupees?|rand|krona|kronor|francs?|pesos?|reais?|real|won|baht|ringgit|crowns?|zloty|forints?|lira|shekels?|dirhams?|riyals?)\b/i
  NUMBER_PAT = /\d[\d,.\s]*\d|\d+/

  MONEY_PATTERN = Regexp.union(
    /(?:#{CURRENCY_PREFIXED}|#{CURRENCY_SYMBOLS})\s*#{NUMBER_PAT}/,
    /#{NUMBER_PAT}\s*(?:#{CURRENCY_PREFIXED}|#{CURRENCY_SYMBOLS})/,
    /#{NUMBER_PAT}\s*#{CURRENCY_WORDS}/,
    /#{CURRENCY_CODES}\s*#{NUMBER_PAT}/,
    /#{NUMBER_PAT}\s*#{CURRENCY_CODES}/
  )

  def extract_money_mentions(text)
    text.scan(MONEY_PATTERN)
  end

  # TF-IDF: compute term frequencies against static IDF table
  def compute_tfidf(text)
    idf = self.class.idf_table
    return {} unless idf

    # Tokenize: lowercase, split on non-word, reject short
    words = text.downcase.split(/\W+/).reject { |w| w.length < 2 }
    return {} if words.empty?

    # Term frequency (normalized)
    tf = Hash.new(0)
    words.each { |w| tf[w] += 1 }
    tf.transform_values! { |c| c.to_f / words.length }

    # TF-IDF for terms in our IDF table
    scores = {}
    tf.each do |term, freq|
      scores[term] = freq * idf[term] if idf.key?(term)
    end
    scores
  end
end
