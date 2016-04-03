require 'spec_helper'

describe 'layouts/application' do
  context 'the html tag' do
    it 'includes the default language locale' do
      view.stubs(:signed_in?).returns(false)

      render

      rendered.should have_selector('html[lang="en"]')
    end

    it 'includes an alternate language locale' do
      I18n.locale = 'fr'

      view.stubs(:signed_in?).returns(false)

      render

      rendered.should have_selector('html[lang="fr"]')
    end
  end

  context 'the header' do
    it 'includes all of the alternate language versions including itself' do
      view.stubs(:signed_in?).returns(false)

      render

      # Can't figure out why have_selector isn't working here
      I18n.available_locales.each do |locale|
        rendered.should include("hreflang=\"#{locale}\" rel=\"alternate\"")
      end
    end
  end
end
