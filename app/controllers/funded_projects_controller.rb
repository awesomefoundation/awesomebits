class FundedProjectsController < ApplicationController
  def index
    @projects = Project.preload(:primary_photo, :chapter).winners.order(funded_on: :desc)

    if params[:q].present?
      @projects = @projects.public_search(params[:q]) if params[:q].present?
    end

    if params[:chapter].present?
      @projects = @projects.joins(:chapter).merge(Chapter.where(slug: params[:chapter]))
    end

    @projects = @projects.paginate(page: params[:page], per_page: 52)

    respond_to do |format|
      format.xml
      format.html do
        @chapters = Chapter.joins(:winning_projects).distinct.select_data(:all, include_any: false).collect { |c| [c.name, c.chapters.collect { |chapter| [chapter.name, chapter.slug] }] }
      end
    end
  end
end
