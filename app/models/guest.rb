class Guest
  def logged_in?
    false
  end

  def trustee?
    false
  end

  def dean?
    false
  end

  def admin?
    false
  end

  def gravatar_url
    Gravatar.new(nil).url
  end

  def can_manage_chapter?(chapter)
    false
  end

  def can_manage_users?(chapter)
    false
  end

  def can_manage_permissions?
    false
  end

  def can_create_chapters?
    false
  end

  def can_invite?
    false
  end

  def can_invite_to_chapter?(chapter)
    false
  end

  def can_view_finalists_for?(chapter)
    false
  end

  def can_mark_winner?(project)
    false
  end

  def can_edit_project?(project)
    false
  end

  def can_edit_profile?(user_id)
    false
  end

  def mark_last_viewed_chapter(chapter_id)
    false
  end
end
