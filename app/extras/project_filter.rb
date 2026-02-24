class ProjectFilter
  def initialize(projects)
    @projects = projects
    @projects = @projects.order(:created_at).reverse_order
  end

  def search(query)
    @projects = @projects.search(query)
    self
  end

  def during(start_date, end_date)
    @projects = @projects.during_timeframe(start_date, end_date)
    self
  end

  def page(page_number, per_page = Project.per_page)
    @projects = @projects.paginate(:page => page_number, :per_page => per_page)
    self
  end

  def shortlisted_by(user)
    @projects = @projects.joins(:votes).where('votes.user_id = ?', user.id)
    self
  end

  def funded
    @projects = @projects.where.not(funded_on: nil)
    self
  end

  def signal_score_above(threshold)
    @projects = @projects.where("(metadata->'signal_score'->>'composite_score')::float >= ?", threshold)
    self
  end

  def sort_by_signal_score(direction = :desc)
    @projects = @projects.reorder(
      Arel.sql("COALESCE((metadata->'signal_score'->>'composite_score')::float, -1) #{direction == :asc ? 'ASC' : 'DESC'}")
    )
    self
  end

  def not_pending_moderation
    @projects = @projects.left_joins(:project_moderation).where(project_moderations: {id: nil}).or(@projects.merge(ProjectModeration.approved))
    self
  end

  def pending_moderation
    @projects = @projects.joins(:project_moderation).merge(ProjectModeration.pending)
    self
  end

  def result
    @projects
  end
end
