class ActionDispatch::Integration::Session
  def default_url_options_with_locale(options = {})
    default_url_options_without_locale.merge(locale: I18n.locale).merge(options)
  end
  alias_method_chain :default_url_options, :locale
end
