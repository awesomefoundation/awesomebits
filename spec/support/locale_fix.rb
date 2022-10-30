module DefaultUrlOptionsWithLocale
  def default_url_options(options = {})
    super({ locale: I18n.locale }.merge(options))
  end
end

ActionDispatch::Integration::Session.send(:prepend, DefaultUrlOptionsWithLocale)

# https://github.com/rspec/rspec-rails/issues/255#issuecomment-20727452
module CallWithLocaleFix
  def call(t, method_name, args, inner_options, url_strategy)
    original_options = @options
    @options = { locale: I18n.locale }.merge(@options)
    result = super
    @options = original_options
    result
  end
end

ActionDispatch::Routing::RouteSet::NamedRouteCollection::UrlHelper.send(:prepend, CallWithLocaleFix)
