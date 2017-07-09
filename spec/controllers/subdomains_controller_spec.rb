require 'spec_helper'

describe SubdomainsController do

  context 'with no subdomain' do
    it { is_expected.to route(:get, "http://test.host").to(:controller => "home", :action => "index") }
  end

  context 'with www subdomain' do
    it { is_expected.to route(:get, "http://www.test.host").to(:controller => "home", :action => "index") }
  end

  context 'with chapter subdomain' do
    it { is_expected.to route(:get, "http://subdomain.test.host").to(:controller => "subdomains", :action => "chapter") }
    it { is_expected.to route(:get, "http://subdomain.test.host/apply").to(:controller => "subdomains", :action => "apply") }

    context 'for a valid chapter' do
      let!(:chapter) { FactoryGirl.create(:chapter, :country => "United States", :locale => "es") }

      before do
        @request.host = "#{chapter.slug}.test.host"
        get :chapter
      end

      it { is_expected.to redirect_to("http://www.test.host/#{chapter.locale}/chapters/#{chapter.slug}") }
    end

    context 'for an invalid chapter' do
      before do
        @request.host = "invalid.test.host"
        get :chapter
      end

      it { is_expected.to redirect_to("http://www.test.host/#{I18n.default_locale}") }
    end
  end
end
