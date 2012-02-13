module ProjectsHelper
  def selectable_chapters_for(user)
    any_chapter = Chapter.where(:name => "Any").first
    if user.admin?
      [any_chapter] + Chapter.where("name != 'Any'").order(:name)
    else
      [any_chapter] + user.chapters.order(:name)
    end
  end
end
