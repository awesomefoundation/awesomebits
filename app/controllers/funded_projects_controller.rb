class FundedProjectsController < ApplicationController
  before_action :find_project, only: [:show]
  before_action :handle_unpublished_projects, only: [:show]
  before_action :canonical_path, only: [:show]

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
        @chapter = Chapter.find(params[:chapter]) if params[:chapter].present?
        @chapters = Chapter.joins(:winning_projects).distinct.select_data(:all, include_any: false).collect { |c| [c.name, c.chapters.collect { |chapter| [chapter.name, chapter.slug] }] }
      end
    end
  end

  def show
  end

  protected

  def find_project
    @project = Project.find(params[:id])
  end

  def handle_unpublished_projects
    unless @project.try(:winner?)
      if current_user.logged_in?
        redirect_to chapter_project_path(@project.chapter, @project) and return
      else
        render_404 and return
      end
    end
  end

  def canonical_path
    # Ensure the canonical path
    if funded_project_path(@project) != request.path
      redirect_to funded_project_path(@project), status: :moved_permanently and return
    end
  end
end
