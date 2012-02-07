module ChaptersHelper

  def can_manage_chapter?(chapter)
    if current_user && current_user.can_manage_chapter?(chapter)
      true
    else
      false
    end
  end

end
