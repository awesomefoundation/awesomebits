module ProjectNavHelper
  def project_winning_siblings(project)
    all_projects = chapter_winning_projects(project).to_a
    project_index = all_projects.index { |obj| obj.id == project.id }
    return [nil, nil] unless project_index

    prev_project = all_projects[project_index - 1] unless project_index.zero?
    next_project = all_projects[project_index + 1] unless project_index == all_projects.count - 1

    [prev_project, next_project]
  end

  private

  def chapter_winning_projects(project)
    project.chapter.winning_projects.order('funded_on DESC')
  end
end
