class ProjectsController < ApplicationController
  before_filter :ensure_chapter_or_admin, :only => [:index]
  before_filter :must_be_logged_in, :except => [:show, :new, :create]
  before_filter :must_be_logged_in_to_see_unpublished_projects, :only => [:show]

  include ApplicationHelper

  def index
    @start_date, @end_date = extract_timeframe
    @chapter = Chapter.find(params[:chapter_id])
    @projects = @chapter.projects.during_timeframe(@start_date, @end_date)
    current_user.last_viewed_chapter_id = @chapter.id
    current_user.save
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(params[:project])
    if @project.save
      flash[:notice] = "Thanks for applying!"
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @project = Project.find(params[:id])
  end

  private

  def current_project
    @current_project ||= Project.find(params[:id])
  end

  def ensure_chapter_or_admin
    if params[:chapter_id].blank?
      if current_user.admin?
        redirect_to chapter_projects_path(Chapter.first)
      else
        redirect_to chapter_projects_path(current_user.chapters.first)
      end
    end
  end

  def must_be_logged_in_to_see_unpublished_projects
    if !current_project.try(:winner?) && !current_user
      flash[:notice] = "You must be logged in."
      redirect_to root_url
    end
  end
end
