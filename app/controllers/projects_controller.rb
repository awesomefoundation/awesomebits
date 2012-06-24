class ProjectsController < ApplicationController
  before_filter :must_be_logged_in, :except => [:show, :new, :create]
  before_filter :verify_user_can_edit, :only => [:destroy]
  before_filter :redirect_to_chapter_or_sign_in, :only => [:index], :if => :chapter_missing?
  before_filter :must_be_logged_in_to_see_unpublished_projects, :only => [:show]

  include ApplicationHelper

  def index
    @chapter = Chapter.find(params[:chapter_id])
    @start_date, @end_date = extract_timeframe
    @short_listed = params[:short_list]
    project_filter = ProjectFilter.new(@chapter.projects).during(@start_date, @end_date)
    if params[:short_list]
      project_filter.shortlisted_by(current_user)
    end
    respond_to do |format|
      format.html do
        @projects = project_filter.page(params[:page]).result
        current_user.mark_last_viewed_chapter(params[:chapter_id])
      end
      format.csv do
        if export_all?
          @projects = Project.during_timeframe(@start_date, @end_date)
        else
          @projects = project_filter.result
        end
        render :text => Project.csv_export(@projects), :content_type => 'text/csv'
      end
    end
  end

  def new
    @project = Project.new

    if params[:chapter]
      @project.chapter = Chapter.find(params[:chapter].downcase) rescue nil
    end
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
      render :edit
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
  helper_method :current_project

  def export_all?
    params[:export_all] && current_user.admin?
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

  def verify_user_can_edit
    unless current_user.can_edit_project?(current_project)
      redirect_to chapter_projects_path(current_project.chapter)
    end
  end

  def chapter_missing?
    params[:chapter_id].blank?
  end

  def must_be_logged_in_to_see_unpublished_projects
    if !current_project.try(:winner?) && !current_user.logged_in?
      flash[:notice] = t("flash.permissions.must-be-logged-in")
      redirect_to root_url
    end
  end
end
