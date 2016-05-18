require 'spec_helper'

describe FundedProjectsController do
  context 'getting an Atom feed of winning projects' do
    let!(:chapter) { FactoryGirl.create(:chapter, country: 'United States') }

    before do
      get :index, format: :xml
    end

    it 'should return parseable XML' do
      response.content_type.should eq('application/xml')
      lambda { Nokogiri::XML(response.body) }.should_not raise_error
    end
  end
end
