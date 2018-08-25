module ProjectNavHelper
  def project_winning_siblings(project)
    prev_project = project.chapter.winning_projects.where(Project.arel_table[:funded_on].gt(project.funded_on)).last
    next_project = project.chapter.winning_projects.where(Project.arel_table[:funded_on].lt(project.funded_on)).first

    [prev_project, next_project]
  end
end
