require 'spec_helper'

describe Role do
  context 'having one in the database' do
    before do
      FactoryGirl.create(:role)
    end
    it { expect(subject).to belong_to :user }
    it { expect(subject).to belong_to :chapter }
    it { expect(subject).to validate_uniqueness_of(:user_id).scoped_to(:chapter_id) }
  end

  it '#trustee? always returns true' do
    expect(Role.new.trustee?).to eq(true)
  end

  context '#dean?' do
    let(:role) { FactoryGirl.build(:role) }
    it 'returns true if this is a dean role' do
      role.name = "dean"
      expect(role.dean?).to be_truthy
    end

    it 'returns false if the user is only a trustee' do
      role.name = 'trustee'
      expect(role.dean?).to be_falsey
    end
  end

  context ".can_invite?" do
    it 'returns true when any role is a dean role' do
      FactoryGirl.create(:role, :name => "dean")
      expect(Role.can_invite?).to be_truthy
    end

    it 'return false if no roles are dean roles' do
      Role.delete_all
      FactoryGirl.create(:role, :name => "trustee")
      expect(Role.can_invite?).to be_falsey
    end
  end

  context ".can_invite_to_chapter?" do
    let(:role) { FactoryGirl.create(:role, :name => "dean") }
    let!(:chapter) { role.chapter }
    let!(:other_chapter) { FactoryGirl.create(:chapter) }
    it 'returns true when we have dean role for this chapter' do
      expect(Role.can_invite_to_chapter?(chapter)).to be_truthy
    end

    it 'returns false if chapter has no dean role' do
      expect(Role.can_invite_to_chapter?(other_chapter)).to be_falsey
      Role.delete_all
      expect(Role.can_invite_to_chapter?(chapter)).to be_falsey
    end
  end

  context ".can_manage_chapter?" do
    let(:role) { FactoryGirl.create(:role, :name => "dean") }
    let!(:chapter) { role.chapter }
    let!(:other_chapter) { FactoryGirl.create(:chapter) }
    it 'returns true when we have dean role for this chapter' do
      expect(Role.can_manage_chapter?(chapter)).to be_truthy
    end

    it 'returns false if chapter has no dean role' do
      expect(Role.can_manage_chapter?(other_chapter)).to be_falsey
      Role.delete_all
      expect(Role.can_manage_chapter?(chapter)).to be_falsey
    end
  end

  context ".can_manage_users?" do
    let(:role) { FactoryGirl.create(:role, :name => "dean") }
    let!(:chapter) { role.chapter }
    let!(:other_chapter) { FactoryGirl.create(:chapter) }
    it 'returns true when we have dean role for this chapter' do
      expect(Role.can_manage_users?(chapter)).to be_truthy
    end

    it 'returns false if chapter has no dean role' do
      expect(Role.can_manage_users?(other_chapter)).to be_falsey
      Role.delete_all
      expect(Role.can_manage_users?(chapter)).to be_falsey
    end
  end

  context ".can_view_finalists_for?" do
    let(:role) { FactoryGirl.create(:role, :name => "trustee") }
    let!(:chapter) { role.chapter }
    let!(:other_chapter) { FactoryGirl.create(:chapter) }

    it 'returns true when we have a trustee role for this chapter' do
      expect(Role.can_view_finalists_for?(chapter)).to be_truthy
    end

    it 'returns false if chapter has no trustee role' do
      expect(Role.can_view_finalists_for?(other_chapter)).to be_falsey
      Role.delete_all
      expect(Role.can_view_finalists_for?(chapter)).to be_falsey
    end
  end

  context ".can_mark_winner?" do
    let(:role) { FactoryGirl.create(:role, :name => "dean") }
    let!(:chapter) { role.chapter }
    let!(:project) { FactoryGirl.create(:project, :chapter => chapter) }
    let!(:other_project) { FactoryGirl.create(:project) }
    it 'returns true when we have dean role for this chapter' do
      expect(Role.can_mark_winner?(project)).to be_truthy
    end

    it 'returns false if chapter has no dean role' do
      expect(Role.can_mark_winner?(other_project)).to be_falsey
      Role.delete_all
      expect(Role.can_mark_winner?(project)).to be_falsey
    end
  end

  context ".can_edit_project?" do
    let(:role) { FactoryGirl.create(:role, :name => "dean") }
    let!(:chapter) { role.chapter }
    let!(:project) { FactoryGirl.create(:project, :chapter => chapter) }
    let!(:other_project) { FactoryGirl.create(:project) }
    it 'returns true when we have dean role for this chapter' do
      expect(Role.can_edit_project?(project)).to be_truthy
    end

    it 'returns false if chapter has no dean role' do
      expect(Role.can_edit_project?(other_project)).to be_falsey
      Role.delete_all
      expect(Role.can_edit_project?(project)).to be_falsey
    end
  end

end
