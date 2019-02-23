# https://github.com/rspec/rspec-rails/issues/255#issuecomment-7858480
class ActionDispatch::Routing::RouteSet
  def url_for_with_locale_fix(options)
    url_for_without_locale_fix({ locale: I18n.locale }.merge(options))
  end

  alias_method_chain :url_for, :locale_fix
end

# https://github.com/rspec/rspec-rails/issues/255#issuecomment-20727452
class ActionDispatch::Routing::RouteSet::NamedRouteCollection::UrlHelper
  def call(t, args)
    t.url_for(handle_positional_args(t, args, { locale: I18n.locale }.merge(@options), @segment_keys))
  end
end
