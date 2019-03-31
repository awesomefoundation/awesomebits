module DefaultUrlOptionsWithLocale
  def default_url_options(options = {})
    super({ locale: I18n.locale }.merge(options))
  end
end

ActionDispatch::Integration::Session.send(:prepend, DefaultUrlOptionsWithLocale)

# https://github.com/rspec/rspec-rails/issues/255#issuecomment-7858480
module UrlForWithLocaleFix
  def url_for(options, route_name = nil, url_strategy = ::ActionDispatch::Routing::RouteSet::UNKNOWN)
    super({ locale: I18n.locale }.merge(options), route_name, url_strategy)
  end
end

ActionDispatch::Routing::RouteSet.send(:prepend, UrlForWithLocaleFix)

# https://github.com/rspec/rspec-rails/issues/255#issuecomment-20727452
module CallWithLocaleFix
  def call(t, args, inner_options)
    original_options = @options
    @options = { locale: I18n.locale }.merge(@options)
    result = super(t, args, inner_options)
    @options = original_options
    result
  end
end

ActionDispatch::Routing::RouteSet::NamedRouteCollection::UrlHelper.send(:prepend, CallWithLocaleFix)
