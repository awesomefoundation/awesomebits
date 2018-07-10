module ProjectNavHelper

  def next_project_id project
    if is_last_project? project
      nil
    else
      all_keys = chapter_projects_keys(project)
      index_next_project = all_keys.index(project.id) + 1
      all_keys[index_next_project]
    end
  end

  def prev_project_id project
    if is_first_project? project
      nil
    else
      all_keys = chapter_projects_keys(project)
      index_prev_project = all_keys.index(project.id) - 1
      all_keys[index_prev_project]
    end
  end

  private

  def chapter_projects_keys(project)
    project.chapter.projects.order(:created_at).pluck(:id)
  end

  def is_last_project? project
    chapter_projects_keys(project).last == project.id
  end

  def is_first_project? project
    chapter_projects_keys(project).first == project.id
  end
end