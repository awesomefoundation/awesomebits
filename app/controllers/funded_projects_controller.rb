class FundedProjectsController < ApplicationController
  def index
    project_filter = ProjectFilter.new(Project.includes(:photos).recent_winners)
    @projects = project_filter.page(params[:page], 50).result

    respond_to do |format|
      format.xml
    end
  end
end
