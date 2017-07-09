require 'spec_helper'

describe CountrySortCriteria do

  let(:chapter1) { FactoryGirl.create(:chapter, :name => 'Salzburg', :country => 'Austria') }
  let(:chapter2) { FactoryGirl.create(:chapter, :name => 'Los Angeles', :country => 'United States') }
  let(:chapter3) { FactoryGirl.create(:chapter, :name => 'Sydney', :country => 'Australia') }
  let(:chapter4) { FactoryGirl.create(:chapter, :name => 'Boston', :country => 'United States') }
  let(:chapter5) { FactoryGirl.create(:chapter, :name => 'Awesome Without Borders', :country => 'Worldwide') }
  let(:chapters) { [chapter1, chapter2, chapter3, chapter4, chapter5] }

  context "given an array of chapters" do
    it "should be sorted based on priorty and country name" do
      expect(chapters.sort_by(&CountrySortCriteria.new(COUNTRY_PRIORITY))).to eq([chapter5, chapter3, chapter1, chapter4, chapter2])
    end
  end

end
