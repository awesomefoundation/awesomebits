require 'spec_helper'

describe ChaptersController do
  context "routing" do
    it "routes /chapters/boston to chapters#show" do
      expect({:get => "/chapters/boston"}).to route_to(
        {:controller => "chapters", :action => "show", :id => "boston"}
      )
    end

    it "routes /en/chapters/boston to chapters#show" do
      expect({:get => "/en/chapters/boston"}).to route_to(
        {:controller => "chapters", :action => "show", :id => "boston", :locale => "en"}
      )
    end
  end

  context "viewing a chapter page with uppercase characters" do
    before do
      get :show, params: { id: "BOSTON" }
    end

    it { is_expected.to redirect_to(chapter_url(:id => "boston")) }
  end

  context "viewing a chapter edit page with uppercase characters" do
    before do
      get :edit, params: { id: "BOSTON" }
    end

    it { is_expected.to redirect_to(edit_chapter_url(:id => "boston")) }
  end

  context "#index" do
    render_views

    before do
      5.times do
        FactoryGirl.create(:project)
      end
    end

    it "renders a JSON request with included projects" do
      get :index, format: :json, params: { include_projects: true }
    end

    it "renders an HTML request" do
      get :index
    end
  end
end

