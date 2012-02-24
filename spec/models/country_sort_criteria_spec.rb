require 'spec_helper'

describe CountrySortCriteria do

  let(:chapter1) { FactoryGirl.create(:chapter, :name => 'Salzburg', :country => 'Austria') }
  let(:chapter2) { FactoryGirl.create(:chapter, :name => 'Los Angeles', :country => 'United States') }
  let(:chapter3) { FactoryGirl.create(:chapter, :name => 'Sydney', :country => 'Australia') }
  let(:chapter4) { FactoryGirl.create(:chapter, :name => 'Boston', :country => 'United States') }
  let(:chapters) { [chapter1, chapter2, chapter3, chapter4] }

  context "given an array of chapters" do
    it "should be sorted based on priorty and country name" do
      chapters.sort_by(&CountrySortCriteria.new(COUNTRY_PRIORITY)).should == [chapter4, chapter2, chapter3, chapter1]
    end
  end

end
