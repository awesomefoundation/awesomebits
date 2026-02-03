require 'spec_helper'

describe UsersController, type: :controller do
  context "signed in as admin user" do
    render_views

    let(:user) { FactoryBot.create(:user, :admin => true) }
    before do
      sign_in_as user
    end

    context "fetching an HTML file" do
      before { get :index }
      it { is_expected.to respond_with(:success) }
      it { should render_template("index") }
    end

    context "fetching a CSV file" do
      before { get :index, format: "csv" }
      it { is_expected.to respond_with(:success) }
      it { should render_template("index") }
    end
  end
  context "signed in as non-admin user" do
    let(:role) { FactoryBot.create(:role) }
    let(:user) { role.user }
    let(:chapter) { role.chapter }
    before do
      sign_in_as user
      get :index
    end
    it { is_expected.to redirect_to(chapter_users_path(chapter)) }
  end
  context "signed out" do
    before do
      sign_out
      get :index
    end
    it { is_expected.to redirect_to(sign_in_path) }
  end
end
