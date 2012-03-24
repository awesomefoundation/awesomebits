class ProjectsController < ApplicationController
  before_filter :must_be_logged_in, :except => [:show, :new, :create]
  before_filter :redirect_to_chapter_or_sign_in, :only => [:index], :if => :chapter_id_blank?
  before_filter :must_be_logged_in_to_see_unpublished_projects, :only => [:show]

  include ApplicationHelper

  def index
    @start_date, @end_date = extract_timeframe
    @chapter = Chapter.find(params[:chapter_id])
    @projects = @chapter.projects.during_timeframe(@start_date, @end_date)
    current_user.mark_last_viewed_chapter(params[:chapter_id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(params[:project])
    if @project.save
      flash[:thanks] = t("flash.applications.thanks")
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @project = Project.find(params[:id])
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update_attributes(params[:project])
      redirect_to @project
    else
      render "edit"
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    redirect_to(projects_path)
  end

  private

  def current_project
    @current_project ||= Project.find(params[:id])
  end

  def current_chapter_for_user
    @current_chapter_for_user ||= Chapter.current_chapter_for_user(current_user)
  end

  def redirect_to_chapter_or_sign_in
    if current_chapter_for_user
      redirect_to chapter_projects_path(current_chapter_for_user)
    else
      redirect_to sign_in_path, notice: t("flash.permissions.must-have-chapter")
    end
  end

  def chapter_id_blank?
    params[:chapter_id].blank?
  end

  def must_be_logged_in_to_see_unpublished_projects
    if !current_project.try(:winner?) && !current_user
      flash[:notice] = t("flash.permissions.must-be-logged-in")
      redirect_to root_url
    end
  end
end
