require 'spec_helper'

describe UsersController do
  context "signed in as admin user" do
    let(:user) { FactoryGirl.create(:user, :admin => true) }
    before do
      sign_in_as user
      get :index
    end
    it { is_expected.to respond_with(:success) }
  end
  context "signed in as non-admin user" do
    let(:role) { FactoryGirl.create(:role) }
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
