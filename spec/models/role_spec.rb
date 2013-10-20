require 'spec_helper'

describe Role do
  context 'having one in the database' do
    before do
      create(:role)
    end
    it { should belong_to :user }
    it { should belong_to :chapter }
    it { should validate_uniqueness_of(:user_id).scoped_to(:chapter_id) }
  end

  it '#trustee? always returns true' do
    Role.new.trustee?.should == true
  end

  context '#dean?' do
    let(:role) { build(:role) }
    it 'returns true if this is a dean role' do
      role.name = "dean"
      role.dean?.should be_true
    end

    it 'returns false if the user is only a trustee' do
      role.name = 'trustee'
      role.dean?.should be_false
    end
  end

  context ".can_invite?" do
    it 'returns true when any role is a dean role' do
      create(:role, name: "dean")
      Role.can_invite?.should be_true
    end

    it 'return false if no roles are dean roles' do
      Role.delete_all
      create(:role, name: "trustee")
      Role.can_invite?.should be_false
    end
  end

  context ".can_invite_to_chapter?" do
    let(:role) { create(:role, name: "dean") }
    let!(:chapter) { role.chapter }
    let!(:other_chapter) { create(:chapter) }
    it 'returns true when we have dean role for this chapter' do
      Role.can_invite_to_chapter?(chapter).should be_true
    end

    it 'returns false if chapter has no dean role' do
      Role.can_invite_to_chapter?(other_chapter).should be_false
      Role.delete_all
      Role.can_invite_to_chapter?(chapter).should be_false
    end
  end

  context ".can_manage_chapter?" do
    let(:role) { create(:role, name: "dean") }
    let!(:chapter) { role.chapter }
    let!(:other_chapter) { create(:chapter) }
    it 'returns true when we have dean role for this chapter' do
      Role.can_manage_chapter?(chapter).should be_true
    end

    it 'returns false if chapter has no dean role' do
      Role.can_manage_chapter?(other_chapter).should be_false
      Role.delete_all
      Role.can_manage_chapter?(chapter).should be_false
    end
  end

  context ".can_remove_users?" do
    let(:role) { create(:role, name: "dean") }
    let!(:chapter) { role.chapter }
    let!(:other_chapter) { create(:chapter) }
    it 'returns true when we have dean role for this chapter' do
      Role.can_remove_users?(chapter).should be_true
    end

    it 'returns false if chapter has no dean role' do
      Role.can_remove_users?(other_chapter).should be_false
      Role.delete_all
      Role.can_remove_users?(chapter).should be_false
    end
  end

  context ".can_view_finalists_for?" do
    let(:role) { create(:role, name: "trustee") }
    let!(:chapter) { role.chapter }
    let!(:other_chapter) { create(:chapter) }

    it 'returns true when we have a trustee role for this chapter' do
      Role.can_view_finalists_for?(chapter).should be_true
    end

    it 'returns false if chapter has no trustee role' do
      Role.can_view_finalists_for?(other_chapter).should be_false
      Role.delete_all
      Role.can_view_finalists_for?(chapter).should be_false
    end
  end

  context ".can_mark_winner?" do
    let(:role) { create(:role, name: "dean") }
    let!(:chapter) { role.chapter }
    let!(:project) { create(:project, chapter: chapter) }
    let!(:other_project) { create(:project) }
    it 'returns true when we have dean role for this chapter' do
      Role.can_mark_winner?(project).should be_true
    end

    it 'returns false if chapter has no dean role' do
      Role.can_mark_winner?(other_project).should be_false
      Role.delete_all
      Role.can_mark_winner?(project).should be_false
    end
  end

  context ".can_edit_project?" do
    let(:role) { create(:role, name: "dean") }
    let!(:chapter) { role.chapter }
    let!(:project) { create(:project, chapter: chapter) }
    let!(:other_project) { create(:project) }
    it 'returns true when we have dean role for this chapter' do
      Role.can_edit_project?(project).should be_true
    end

    it 'returns false if chapter has no dean role' do
      Role.can_edit_project?(other_project).should be_false
      Role.delete_all
      Role.can_edit_project?(project).should be_false
    end
  end

end
