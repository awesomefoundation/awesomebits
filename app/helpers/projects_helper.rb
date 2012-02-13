module ProjectsHelper
  def selectable_chapters_for(user)
    any_chapter = Chapter.where(:name => "Any").first
    [any_chapter] + user.chapters.sort_by(&:name)
  end
end
