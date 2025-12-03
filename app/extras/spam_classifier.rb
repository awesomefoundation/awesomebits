class SpamClassifier
  attr_accessor :score, :signals

  def initialize(project)
    @project = project
    @metadata = project&.metadata || {}
    @score = 0
    @signals = []
    @config = SpamConfig.new
  end

  def analyze!
    @score = 0
    @signals = []

    # Check for missing metadata (bot indicator)
    if all_js_fields_missing?
      self.signals << "missing_js_metadata"
      self.score += @config.weight_missing_js_metadata
    end

    # Very short time on page (less than 10 seconds)
    if @metadata["time_on_page_ms"].present? && @metadata["time_on_page_ms"].to_i < @config.time_on_page_threshold_ms
      self.signals << "short_time_on_page"
      self.score += @config.weight_short_time_on_page
    end

    # No referrer (direct access, often bots)
    if @metadata["referrer"].blank?
      self.signals << "no_referrer"
      self.score += @config.weight_no_referrer
    end

    # Suspicious user agents
    if suspicious_user_agent?
      self.signals << "suspicious_user_agent"
      self.score += @config.weight_suspicious_user_agent
    end

    # Very few form interactions
    if @metadata["form_interactions_count"].present? && @metadata["form_interactions_count"].to_i < @config.min_form_interactions
      self.signals << "low_form_interactions"
      self.score += @config.weight_low_form_interactions
    end

    # High paste to keystroke ratio (copy-paste behavior)
    if high_paste_ratio?
      self.signals << "high_paste_ratio"
      self.score += @config.weight_high_paste_ratio
    end

    # Common bot screen resolutions
    if bot_screen_resolution?
      self.signals << "bot_screen_resolution"
      self.score += @config.weight_bot_screen_resolution
    end

    # Gibberish fields detection
    if gibberish_fields?
      self.signals << "gibberish_fields"
      self.score += @config.weight_gibberish_fields
    end

    # Nearly identical fields
    if identical_fields?
      self.signals << "identical_fields"
      self.score += @config.weight_identical_fields
    end

    analysis
  end

  def suspected_spam?
    score >= @config.threshold
  end

  def analysis
    {
      score: score,
      triggered: signals
    }
  end

  private

  def all_js_fields_missing?
    js_fields = ["time_on_page_ms", "timezone", "screen_resolution", "form_interactions_count", "keystroke_count", "paste_count"]
    js_fields.all? { |field| @metadata[field].blank? }
  end

  def suspicious_user_agent?
    return false if @metadata["user_agent"].blank?

    user_agent = @metadata["user_agent"].downcase

    # Check for quoted user agents (clear bot indicator)
    return true if user_agent.start_with?('"') && user_agent.end_with?('"')

    suspicious_patterns = ["headlesschrome", "phantomjs", "selenium", "bot", "crawler", "spider"]
    suspicious_patterns.any? { |pattern| user_agent.include?(pattern) }
  end

  def high_paste_ratio?
    return false if @metadata["keystroke_count"].blank? || @metadata["paste_count"].blank?

    keystrokes = @metadata["keystroke_count"].to_i
    pastes = @metadata["paste_count"].to_i

    return false if keystrokes == 0

    paste_ratio = pastes.to_f / keystrokes
    paste_ratio > @config.paste_ratio_threshold
  end

  def bot_screen_resolution?
    return false if @metadata["screen_resolution"].blank?

    resolution = @metadata["screen_resolution"]
    # Common headless browser resolutions
    bot_resolutions = ["1024x768", "1280x1024", "800x600"]
    bot_resolutions.include?(resolution)
  end

  def gibberish_fields?
    # Check these fields for gibberish (single words with no spaces)
    fields_to_check = %w[name title about_me use_for_money about_project extra_answer_1 extra_answer_2 extra_answer_3]

    gibberish_count = 0

    fields_to_check.each do |field|
      value = @project.send(field)
      next if value.blank?

      # Check if it's a single word (no spaces) and not empty
      if value.strip.match?(/\A\S+\z/) && value.length > 1
        gibberish_count += 1
      end
    end

    # If more than threshold fields are single words, likely gibberish
    gibberish_count > @config.gibberish_field_threshold
  end

  def identical_fields?
    fields_to_check = %w[about_me use_for_money about_project]

    # Find the length of the shortest field
    min_length = fields_to_check.collect { |field| @project.send(field).length if @project.send(field).present? }.compact.min

    # Make all the strings the same length and see if their contents are the same
    fields_to_check.collect { |field| @project.send(field)[0, min_length] }.uniq.length == 1
  end
end
