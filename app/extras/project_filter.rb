class ProjectFilter
  def initialize(projects)
    @projects = projects
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

  def result
    @projects = @projects.order(:created_at).reverse_order
    @projects
  end
end
