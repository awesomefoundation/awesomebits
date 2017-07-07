require 'spec_helper'

describe FundedProjectsController do
  context 'getting an Atom feed of winning projects' do
    let!(:chapter) { FactoryGirl.create(:chapter, country: 'United States') }

    before do
      get :index, format: :xml
    end

    it 'should return parseable XML' do
      expect(response.content_type).to eq('application/xml')
      expect { Nokogiri::XML(response.body) }.not_to raise_error
    end
  end
end
