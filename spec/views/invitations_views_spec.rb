require 'spec_helper'

describe 'invitations/new' do

  let!(:role) { create(:role, name: 'dean') }
  let!(:user) { role.user }
  let!(:chapter) { role.chapter }
  let!(:another_role) { create(:role, name: 'dean', user: user) }
  let!(:another_chapter) { another_role.chapter }
  let!(:invitation) { Invitation.new }

  it 'renders a chapter drop down when dean of multiple chapters' do
    assign(:chapter, chapter)
    assign(:invitation, invitation)
    view.stubs(:current_user).returns(user)
    view.stubs(:show_chapters_dropdown?).returns(true)
    view.stubs(:invitable_chapters).returns([chapter, another_chapter])
    render
    rendered.should have_content("Select a chapter")
  end

  it 'renders a chapter hidden field when dean of one chapter' do
    assign(:chapter, chapter)
    assign(:invitation, invitation)
    view.stubs(:current_user).returns(user)
    view.stubs(:show_chapters_dropdown?).returns(false)
    view.stubs(:primary_invitable_chapter).returns(chapter)
    render
    rendered.should_not have_content("Select a chapter")
  end

end
