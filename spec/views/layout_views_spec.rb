require 'spec_helper'

describe 'layouts/application' do
  it 'includes the default language locale in the html tag' do
    view.stubs(:signed_in?).returns(false)

    render

    rendered.should have_selector('html[lang="en"]')
  end

  it 'includes an alternate language locale in the html tag' do
    I18n.locale = 'fr'

    view.stubs(:signed_in?).returns(false)

    render

    rendered.should have_selector('html[lang="fr"]')
  end
end
