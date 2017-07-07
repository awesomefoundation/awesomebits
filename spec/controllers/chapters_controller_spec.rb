require 'spec_helper'

describe ChaptersController do
  context "routing" do
    let(:boston){ FactoryGirl.build_stubbed(:chapter) }

    it "routes /chapters/boston to chapters#show" do
      expect({:get => "/chapters/boston"}).to
        route_to({:controller => "chapters", :action => "show", :id => boston.id, :locale => "en"})
    end

    it "routes /en/chapters/boston to chapters#show" do
      expect({:get => "/en/chapters/boston"}).to
        route_to({:controller => "chapters", :action => "show", :id => boston.id, :locale => "en"})
    end
  end

  context "viewing a chapter page with uppercase characters" do 
    before do 
      get :show, :id => "BOSTON"
    end

    it { is_expected.to redirect_to(chapter_url(:id => "boston")) }
  end

  context "viewing a chapter edit page with uppercase characters" do
    before do
      get :edit, :id => "BOSTON"
    end

    it { is_expected.to redirect_to(edit_chapter_url(:id => "boston")) }
  end
end

