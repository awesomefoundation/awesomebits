require 'spec_helper'

describe 'layouts/application' do
  before(:each) do
    controller.request.path_parameters[:controller] = "home"
    controller.request.path_parameters[:action] = "index"
  end

  context 'the html tag' do
    it 'includes the default language locale' do
      view.stubs(:signed_in?).returns(false)

      render

      expect(rendered).to have_selector('html[lang="en"]')
    end

    it 'includes an alternate language locale' do
      I18n.locale = 'fr'

      view.stubs(:signed_in?).returns(false)

      render

      expect(rendered).to have_selector('html[lang="fr"]')
    end
  end

  context 'the header' do
    it 'includes all of the alternate language versions including itself' do
      view.stubs(:signed_in?).returns(false)

      render

      # Can't figure out why have_selector isn't working here
      I18n.available_locales.each do |locale|
        expect(rendered).to include("rel=\"alternate\" hreflang=\"#{locale}\"")
      end
    end
  end
end
