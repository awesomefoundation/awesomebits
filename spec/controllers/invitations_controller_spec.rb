require 'spec_helper'

describe InvitationsController do
  let(:chapter) { FactoryGirl.create(:chapter) }

  context 'not logged in' do
    context 'GET to #new' do
      before do
        get :new, :chapter_id => chapter.id
      end
      it { should redirect_to(root_path) }
      it 'sets the flash' do
        flash[:notice].should == "You must be logged in."
      end
    end
  end

  context 'logged in as a dean' do
    let(:other_chapter) { FactoryGirl.create(:chapter) }
    let(:user) { FactoryGirl.create(:user) }
    let(:role) { FactoryGirl.create(:role, :user => user, :chapter => chapter, :name => "dean") }
    context 'GET to #new for the right chapter' do
      before do
        controller.send(:current_user=, user)
        get :new, :chapter_id => chapter.id
      end
      it { should render_template(nil) }
    end
    context 'GET to #new for the wrong chapter' do
      before do
        controller.send(:current_user=, user)
        get :new, :chapter_id => other_chapter.id
      end
      it { should redirect_to(root_path) }
      it 'sets the flash' do
        flash[:notice].should == "You cannot invite new trustees for that chapter."
      end
    end
  end
end
