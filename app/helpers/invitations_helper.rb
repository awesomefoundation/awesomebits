module InvitationsHelper

  def show_chapters_dropdown?
    if Chapter.invitable_by(current_user).count > 1 || current_user.admin
      true
    else
      false
    end
  end

  def invitable_chapters
    Chapter.invitable_by(current_user).order(:name)
  end

  def primary_invitable_chapter
    Chapter.invitable_by(current_user).first
  end

end
