module InvitationsHelper

  def generate_chapter_select
    if Chapter.invitable_by(current_user).count > 1
      true
    else
      false
    end
  end

  def chapters_collection
    Chapter.invitable_by(current_user)
  end

  def current_chapter
    Chapter.invitable_by(current_user).first
  end

end
