class HomeController < ApplicationController
  def index
    @chapters = Chapter.active.visitable.for_display.all
    @projects = Project.recent_winners.limit(15).all
  end

  def feed
    project_filter = ProjectFilter.new(Project.recent_winners)
    @projects = project_filter.page(params[:page], 50).result

    respond_to do |format|
      format.xml
    end
  end
end
