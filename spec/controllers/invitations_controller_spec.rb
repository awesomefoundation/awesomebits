require 'spec_helper'

describe InvitationsController do
  let(:chapter) { create(:chapter) }

  context 'not logged in' do
    context 'GET to #new' do
      before do
        get :new
      end
      it { should redirect_to(root_path) }
      it 'sets the flash' do
        flash[:notice].should == "You must be logged in."
      end
    end
  end

  context 'logged in as a trustee' do
    let(:other_chapter) { create(:chapter) }
    let(:user) { create(:user) }
    let(:role) { create(:role, user: user, chapter: chapter, name: "trustee") }
    context 'GET to #new' do
      before do
        sign_in_as user
        get :new
      end
      it { should redirect_to(root_path) }
      it 'sets the flash' do
        flash[:notice].should == "You do not have permission to invite others."
      end
    end
  end

  context 'logged in as a dean' do
    let(:user) { role.user }
    let(:role) { create(:role, name: "dean") }
    context 'GET to #new' do
      before do
        sign_in_as user
        get :new
      end
      it { should respond_with(:success) }
    end
  end
end
