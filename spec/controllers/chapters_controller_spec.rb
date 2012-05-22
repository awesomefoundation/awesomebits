require 'spec_helper'

describe ChaptersController do
  context "routing" do
    let(:boston){ FactoryGirl.build_stubbed(:chapter) }
    it "routes /chapters/boston to chapters#show" do
      {:get => "/chapters/boston"}.should
        route_to({:controller => "chapters", :action => "show", :id => boston.id, :locale => "en"})
    end
    it "routes /en/chapters/boston to chapters#show" do
      {:get => "/en/chapters/boston"}.should
        route_to({:controller => "chapters", :action => "show", :id => boston.id, :locale => "en"})
    end
  end
end

