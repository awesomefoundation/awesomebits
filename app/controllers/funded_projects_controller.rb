class FundedProjectsController < ApplicationController
  def index
    @projects = Project.includes(:photos).winners.order("funded_on DESC").paginate(:page => params[:page], :per_page => 50)

    respond_to do |format|
      format.xml
      format.html { render_404 }
    end
  end
end
