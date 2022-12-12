require 'spec_helper'

describe SubdomainsController do

  context 'with no subdomain' do
    it { is_expected.to route(:get, "http://test.host").to(:controller => "home", :action => "index") }
  end

  context 'with www subdomain' do
    it { is_expected.to route(:get, "http://www.test.host").to(:controller => "home", :action => "index") }
  end

  context "with ENV subdomain" do
    before do
      ENV["SUBDOMAIN"] = "env"
    end

    it { is_expected.to route(:get, "http://env.test.host").to(:controller => "home", :action => "index") }
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

  context "with canonical host" do
    around(:each) do |example|
      ENV['CANONICAL_HOST'] = "www.test.host"
      example.run
      ENV['CANONICAL_HOST'] = nil
    end

    before do
      @request.host = "www.dummy.test.host"
    end

    it { is_expected.to route(:get, "http://www.dummy.test.host").to(controller: "subdomains", action: "canonical") }
    it { is_expected.to route(:get, "http://www.dummy.test.host/en/projects").to(controller: "subdomains", action: "canonical", url: "en/projects") }
    it { is_expected.to route(:get, "http://nyc.test.host").to(controller: "subdomains", action: "chapter") }

    it "should redirect homepage without locale" do
      get :canonical

      expect(response).to redirect_to("http://www.test.host/")
    end

    it "should redirect project page with locale" do
      get :canonical, params: { url: "pt/projects" }
      expect(response).to redirect_to("http://www.test.host/pt/projects")
    end
  end
end
