module InvitationsHelper

  def chapters_dropdown?
    if Chapter.invitable_by(current_user).count > 1 || current_user.admin
      true
    else
      false
    end
  end

  def chapters_collection
    Chapter.invitable_by(current_user)
  end

  def chapter
    Chapter.invitable_by(current_user).first
  end

end
