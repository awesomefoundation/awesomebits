require 'spec_helper'

describe User do
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:encrypted_password) }
  it { is_expected.to have_many(:roles) }
  it { is_expected.to have_many(:chapters).through(:roles) }
  it { is_expected.to have_many(:votes) }
  it { is_expected.to have_many(:projects).through(:votes) }

  context "#trustee?" do
    let(:user){ FactoryBot.build(:user) }
    let(:chapter){ FactoryBot.build(:chapter) }
    let(:role){ FactoryBot.build(:role, :user => user, :chapter => chapter) }
    before do
      user.roles = [role]
    end

    it 'returns true if the user is a trustee anywhere' do
      expect(user.trustee?).to be_truthy
    end

    it 'returns false if the user is not a trustee anywhere' do
      user.roles = []
      expect(user.trustee?).to be_falsey
    end

    it 'returns true if the user is only a dean somewhere' do
      role.name = "dean"
      expect(user.trustee?).to be_truthy
    end

    it 'returns true if the user is an admin' do
      user.admin = true
      user.roles = []
      expect(user.trustee?).to be_truthy
    end
  end

  context '#can_invite?' do
    let(:user) { FactoryBot.build(:user) }
    it 'returns true if the user is an admin' do
      user.admin = true
      expect(user.can_invite?).to be_truthy
    end
    it 'asks the roles if it can invite if not an admin' do
      user.admin = false
      user.roles.stubs(:can_invite?)
      user.can_invite?
      expect(user.roles).to have_received(:can_invite?)
    end
  end

  context '#can_invite_to_chapter?' do
    let(:user) { FactoryBot.build(:user) }
    it 'returns true if the user is an admin' do
      user.admin = true
      expect(user.can_invite_to_chapter?(:chapter)).to be_truthy
    end
    it 'asks the roles if it can invite if not an admin' do
      user.admin = false
      user.roles.stubs(:can_invite_to_chapter?)
      user.can_invite_to_chapter?(:chapter)
      expect(user.roles).to have_received(:can_invite_to_chapter?)
    end
  end

  context "#can_manage_chapter?" do
    let(:user) { FactoryBot.build(:user) }
    it 'returns true if the user is an admin' do
      user.admin = true
      expect(user.can_manage_chapter?(:chapter)).to be_truthy
    end
    it 'asks the roles if it can manage if not an admin' do
      user.admin = false
      user.roles.stubs(:can_manage_chapter?)
      user.can_manage_chapter?(:chapter)
      expect(user.roles).to have_received(:can_manage_chapter?)
    end
  end

  context "#can_manage_users?" do
    let(:user) { FactoryBot.build(:user) }
    it 'returns true if the user is an admin' do
      user.admin = true
      expect(user.can_manage_chapter?(:chapter)).to be_truthy
    end
    it 'asks the roles if it can manage if not an admin' do
      user.admin = false
      user.roles.stubs(:can_manage_users?)
      user.can_manage_users?(:chapter)
      expect(user.roles).to have_received(:can_manage_users?)
    end
  end

  context "#can_view_finalists_for?" do
    let(:user) { FactoryBot.build(:user) }
    it 'returns true if the user is an admin' do
      user.admin = true
      expect(user.can_view_finalists_for?(:chapter)).to be_truthy
    end
    it 'asks the roles if it can view finalists if not an admin' do
      user.admin = false
      user.roles.stubs(:can_view_finalists_for?)
      user.can_view_finalists_for?(:chapter)
      expect(user.roles).to have_received(:can_view_finalists_for?)
    end
  end

  context "#can_edit_project?" do
    let(:user) { FactoryBot.build(:user) }
    it 'returns true if the user is an admin' do
      user.admin = true
      expect(user.can_edit_project?(:chapter)).to be_truthy
    end
    it 'asks the roles if it can view finalists if not an admin' do
      user.admin = false
      user.roles.stubs(:can_edit_project?)
      user.can_edit_project?(:chapter)
      expect(user.roles).to have_received(:can_edit_project?)
    end
  end

  context "#can_edit_all_profiles?" do
    let(:user) { FactoryBot.build(:user) }
    it 'returns true if the user is an admin' do
      user.admin = true
      expect(user.can_edit_all_profiles?).to be_truthy
    end
    it 'returns false if the user is not an admin' do
      user.admin = false
      expect(user.can_edit_all_profiles?).to be_falsey
    end
  end

  context "#can_mark_winner?" do
    let(:user) { FactoryBot.build(:user) }
    let(:project) { stub }
    it 'returns true if the user is an admin' do
      project.stubs(:in_any_chapter?).returns(false)
      user.admin = true
      expect(user.can_mark_winner?(project)).to be_truthy
    end
    it 'asks the roles if it can manage if not an admin' do
      project.stubs(:in_any_chapter?).returns(false)
      user.admin = false
      user.roles.stubs(:can_mark_winner?)
      user.can_mark_winner?(project)
      expect(user.roles).to have_received(:can_mark_winner?)
    end
    it 'returns true if the project is in the Any chapter' do
      project.stubs(:in_any_chapter?).returns(true)
      user.admin = false
      user.can_mark_winner?(project)
    end
  end

  context ".deans_first" do
    let(:chapter){ FactoryBot.create(:chapter) }
    let!(:trustee){ FactoryBot.create(:role, :chapter => chapter) }
    let!(:dean){ FactoryBot.create(:role, :name => "dean", :chapter => chapter) }
    it 'orders the users so deans are first' do
      expect(chapter.users.deans_first).to eq([dean.user, trustee.user])
    end
  end

  context ".including_role" do
    let(:chapter){ FactoryBot.create(:chapter) }
    let!(:trustee){ FactoryBot.create(:role, :chapter => chapter) }
    let!(:dean){ FactoryBot.create(:role, :name => "dean", :chapter => chapter) }
    it 'includes the role name on the records' do
      expect(User.including_role.where(:id => dean.user.id).first.role).to eq("dean")
      expect(User.including_role.where(:id => trustee.user.id).first.role).to eq("trustee")
    end
  end

  context ".all_with_chapter" do
    let!(:chapter) { FactoryBot.create(:chapter) }
    let!(:trustee) { FactoryBot.create(:user) }
    let!(:role) { FactoryBot.create(:role, :user => trustee, :chapter => chapter) }
    let!(:admin) { FactoryBot.create(:user) }
    it 'includes all users' do
      expect(User.all_with_chapter(nil)).to eq([trustee, admin])
    end
    it 'includes only trustees for chapter' do
      expect(User.all_with_chapter(chapter.id)).to eq([trustee])
    end
  end

  context "url validation" do
    let(:user){ FactoryBot.build(:user) }

    it 'adds a url scheme if it does not have one' do
      user.url = 'example.com'
      user.valid?

      expect(user.url).to eq('http://example.com')
    end

    it 'leaves the scheme alone if it has one' do
      user.url = 'https://example.com'
      user.valid?

      expect(user.url).to eq('https://example.com')
    end

    it 'leaves the url blank if it is blank' do
      user.url = ''
      user.valid?

      expect(user.url).to eq('')
    end

    it 'allows mailto scheme' do
      user.url = 'mailto:awesome@example.com'
      user.valid?

      expect(user.url).to eq('mailto:awesome@example.com')
    end
  end

end
