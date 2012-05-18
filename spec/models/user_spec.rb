require 'spec_helper'

describe User do
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:encrypted_password) }
  it { should have_many(:roles) }
  it { should have_many(:chapters).through(:roles) }
  it { should have_many(:votes) }
  it { should have_many(:projects).through(:votes) }

  context "#trustee?" do
    let(:user){ build(:user) }
    let(:chapter){ build(:chapter) }
    let(:role){ build(:role, :user => user, :chapter => chapter) }
    before do
      user.roles = [role]
    end

    it 'returns true if the user is a trustee anywhere' do
      user.trustee?.should be_true
    end

    it 'returns false if the user is not a trustee anywhere' do
      user.roles = []
      user.trustee?.should be_false
    end

    it 'returns true if the user is only a dean somewhere' do
      role.name = "dean"
      user.trustee?.should be_true
    end

    it 'returns true if the user is an admin' do
      user.admin = true
      user.roles = []
      user.trustee?.should be_true
    end
  end

  context '#can_invite?' do
    let(:user) { build(:user) }
    it 'returns true if the user is an admin' do
      user.admin = true
      user.can_invite?.should be_true
    end
    it 'asks the roles if it can invite if not an admin' do
      user.admin = false
      user.roles.stubs(:can_invite?)
      user.can_invite?
      user.roles.should have_received(:can_invite?)
    end
  end

  context '#can_invite_to_chapter?' do
    let(:user) { build(:user) }
    it 'returns true if the user is an admin' do
      user.admin = true
      user.can_invite_to_chapter?(:chapter).should be_true
    end
    it 'asks the roles if it can invite if not an admin' do
      user.admin = false
      user.roles.stubs(:can_invite_to_chapter?)
      user.can_invite_to_chapter?(:chapter)
      user.roles.should have_received(:can_invite_to_chapter?)
    end
  end

  context "#can_manage_chapter?" do
    let(:user) { build(:user) }
    it 'returns true if the user is an admin' do
      user.admin = true
      user.can_manage_chapter?(:chapter).should be_true
    end
    it 'asks the roles if it can manage if not an admin' do
      user.admin = false
      user.roles.stubs(:can_manage_chapter?)
      user.can_manage_chapter?(:chapter)
      user.roles.should have_received(:can_manage_chapter?)
    end
  end

  context "#can_view_finalists_for?" do
    let(:user) { build(:user) }
    it 'returns true if the user is an admin' do
      user.admin = true
      user.can_view_finalists_for?(:chapter).should be_true
    end
    it 'asks the roles if it can view finalists if not an admin' do
      user.admin = false
      user.roles.stubs(:can_view_finalists_for?)
      user.can_view_finalists_for?(:chapter)
      user.roles.should have_received(:can_view_finalists_for?)
    end
  end

  context "#can_mark_winner?" do
    let(:user) { build(:user) }
    let(:project) { stub }
    it 'returns true if the user is an admin' do
      project.stubs(:in_any_chapter?).returns(false)
      user.admin = true
      user.can_mark_winner?(project).should be_true
    end
    it 'asks the roles if it can manage if not an admin' do
      project.stubs(:in_any_chapter?).returns(false)
      user.admin = false
      user.roles.stubs(:can_mark_winner?)
      user.can_mark_winner?(project)
      user.roles.should have_received(:can_mark_winner?)
    end
    it 'returns true if the project is in the Any chapter' do
      project.stubs(:in_any_chapter?).returns(true)
      user.admin = false
      user.can_mark_winner?(project)
    end
  end

  context ".deans_first" do
    let(:chapter){ create(:chapter) }
    let!(:trustee){ create(:role, :chapter => chapter) }
    let!(:dean){ create(:role, :name => "dean", :chapter => chapter) }
    it 'orders the users so deans are first' do
      chapter.users.deans_first.should == [dean.user, trustee.user]
    end
  end

  context ".including_role" do
    let(:chapter){ create(:chapter) }
    let!(:trustee){ create(:role, :chapter => chapter) }
    let!(:dean){ create(:role, :name => "dean", :chapter => chapter) }
    it 'includes the role name on the records' do
      User.including_role.where(:id => dean.user.id).first.role.should == "dean"
      User.including_role.where(:id => trustee.user.id).first.role.should == "trustee"
    end
  end

  context ".all_with_chapter" do
    let!(:chapter) { create(:chapter) }
    let!(:trustee) { create(:user) }
    let!(:role) { create(:role, :user => trustee, :chapter => chapter) }
    let!(:admin) { create(:user) }
    it 'includes all users' do
      User.all_with_chapter(nil).should == [trustee, admin]
    end
    it 'includes only trustees for chapter' do
      User.all_with_chapter(chapter.id).should == [trustee]
    end
  end

end
