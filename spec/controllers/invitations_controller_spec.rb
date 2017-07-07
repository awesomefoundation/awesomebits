require 'spec_helper'

describe InvitationsController do
  let(:chapter) { FactoryGirl.create(:chapter) }

  context 'not logged in' do
    context 'GET to #new' do
      before do
        get :new
      end
      it { is_expected.to redirect_to(root_path) }
      it 'sets the flash' do
        expect(flash[:notice]).to eq("You must be logged in.")
      end
    end
  end

  context 'logged in as a trustee' do
    let(:other_chapter) { FactoryGirl.create(:chapter) }
    let(:user) { FactoryGirl.create(:user) }
    let(:role) { FactoryGirl.create(:role, :user => user, :chapter => chapter, :name => "trustee") }
    context 'GET to #new' do
      before do
        sign_in_as user
        get :new
      end
      it { is_expected.to redirect_to(root_path) }
      it 'sets the flash' do
        expect(flash[:notice]).to eq("You do not have permission to invite others.")
      end
    end
  end

  context 'logged in as a dean' do
    let(:user) { role.user }
    let(:role) { FactoryGirl.create(:role, :name => "dean") }
    context 'GET to #new' do
      before do
        sign_in_as user
        get :new
      end
      it { is_expected.to respond_with(:success) }
    end
  end
end
