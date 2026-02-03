class SpamConfig < Anyway::Config
  attr_config(
    threshold: 0.85,
    weight_missing_js_metadata: 0.2,
    weight_short_time_on_page: 0.3,
    weight_no_referrer: 0.2,
    weight_suspicious_user_agent: 0.8,
    weight_low_form_interactions: 0.4,
    weight_high_paste_ratio: 0.3,
    weight_bot_screen_resolution: 0.2,
    weight_gibberish_fields: 0.5,
    weight_identical_fields: 0.8,
    time_on_page_threshold_ms: 10000,
    min_form_interactions: 2,
    gibberish_field_threshold: 3,
    paste_ratio_threshold: 0.5
  )
end
