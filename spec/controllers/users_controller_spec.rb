require 'spec_helper'

describe UsersController do
  context "signed in as admin user" do
    let(:user) { create(:user, admin: true) }
    before do
      sign_in_as user
      get :index
    end
    it { should respond_with(:success) }
  end
  context "signed in as non-admin user" do
    let(:role) { create(:role) }
    let(:user) { role.user }
    let(:chapter) { role.chapter }
    before do
      sign_in_as user
      get :index
    end
    it { should redirect_to(chapter_users_path(chapter)) }
  end
  context "signed out" do
    before do
      sign_out
      get :index
    end
    it { should redirect_to(root_url) }
  end
end
