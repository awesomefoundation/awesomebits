require 'spec_helper'

describe HighVoltage::PagesController, '#show' do
  render_views

  %w(about_us faq start_a_chapter).each do |page|
    %w(bg en es fr hy pt ru).each do |locale|
      context "on GET to /#{locale}/#{page}" do
        before do
          get :show, params: { id: page, locale: locale }
        end

        it { is_expected.to respond_with(:success) }
        it { is_expected.to render_template(page) }
      end
    end
  end
end
