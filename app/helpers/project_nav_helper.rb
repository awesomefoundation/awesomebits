module ProjectNavHelper

  def next_project_id(project)
    return if is_last_project? project

    all_keys = chapter_projects_keys(project)
    index_next_project = all_keys.index(project.id) + 1
    all_keys[index_next_project]
  end

  def prev_project_id(project)
    return if is_first_project? project

    all_keys = chapter_projects_keys(project)
    index_prev_project = all_keys.index(project.id) - 1
    all_keys[index_prev_project]
  end

  private

  def chapter_projects_keys(project)
    project.chapter.projects.order('funded_on DESC').pluck(:id)
  end

  def is_last_project?(project)
    chapter_projects_keys(project).last == project.id
  end

  def is_first_project?(project)
    chapter_projects_keys(project).first == project.id
  end
end
