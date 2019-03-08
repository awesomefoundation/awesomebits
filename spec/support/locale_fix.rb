# https://github.com/rspec/rspec-rails/issues/255#issuecomment-7858480
class ActionDispatch::Routing::RouteSet
  def url_for_with_locale_fix(options, route_name = nil, url_strategy = UNKNOWN)
    url_for_without_locale_fix({ locale: I18n.locale }.merge(options), route_name, url_strategy)
  end

  alias_method_chain :url_for, :locale_fix
end

# https://github.com/rspec/rspec-rails/issues/255#issuecomment-20727452
class ActionDispatch::Routing::RouteSet::NamedRouteCollection::UrlHelper
  def call_with_locale_fix(t, args, inner_options)
    original_options = @options
    @options = { locale: I18n.locale }.merge(@options)
    result = call_without_locale_fix(t, args, inner_options)
    @options = original_options
    result
  end

  alias_method_chain :call, :locale_fix
end
