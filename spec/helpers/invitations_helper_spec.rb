require "spec_helper"

describe InvitationsHelper do

  let!(:role) { create(:role, name: 'dean') }
  let!(:user) { role.user }
  let!(:chapter) { role.chapter }
  let!(:another_role) { create(:role, name: 'dean', user: user) }
  let!(:another_chapter) { another_role.chapter }
  let!(:yet_another_role) { create(:role, name: 'dean', user: user) }
  let!(:yet_another_chapter) { yet_another_role.chapter }
  let!(:invitation) { Invitation.new }

  describe '#show_chapters_dropdown' do
    it 'checks if more than one chapter avaiable to user' do
      helper.stubs(:current_user).returns(user)
      helper.show_chapters_dropdown?.should == true
    end
  end

  describe '#invitable_chapters' do
    it 'returns an array of chapters available to user, alphabetically by name' do
      helper.stubs(:current_user).returns(user)
      chapter.update_attributes(name: "Alpha")
      another_chapter.update_attributes(name: "Gamma")
      yet_another_chapter.update_attributes(name: "Beta")
      helper.invitable_chapters.should == [chapter, yet_another_chapter, another_chapter]
    end
  end

  describe '#primary_invitable_chapter' do
    it 'returns the single chapter available to user' do
      helper.stubs(:current_user).returns(user)
      helper.primary_invitable_chapter.should == chapter
    end
  end

end
