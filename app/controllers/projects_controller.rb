class ProjectsController < ApplicationController
  before_filter :must_be_logged_in, :except => [:show, :new, :create]
  before_filter :verify_user_can_edit, :only => [:destroy]
  before_filter :redirect_to_chapter_or_sign_in, :only => [:index], :if => :chapter_missing?
  before_filter :handle_unpublished_projects, :only => [:show]
  before_filter :find_chapter, :only => [:index, :show]

  around_filter :set_time_zone, :only => [:index, :show]

  include ApplicationHelper

  def index
    @start_date, @end_date = extract_timeframe
    @short_listed = params[:short_list]
    project_filter = ProjectFilter.new(@chapter.projects).during(@start_date, @end_date)
    if params[:short_list]
      project_filter.shortlisted_by(current_user)
    end
    @q = params[:q].to_s.strip
    unless @q.blank?
      project_filter.search(@q)
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

        headers["Content-Disposition"] = "attachment; filename=#{@chapter.slug}_export.csv"
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

    if public_view?
      # Ensure the canonical path
      if project_path(@project) != request.path
        redirect_to project_path(@project), :status => :moved_permanently and return
      end

      render :action => "public_show"

    else
      must_be_logged_in || render
    end
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

  def hide
    @project = Project.find(params[:id])
    if params[:hidden_reason].present?
      @project.hide!(params[:hidden_reason], current_user)
      redirect_to chapter_projects_path(@project.chapter_id, anchor: "project#{@project.id}")
    else
      flash[:notice] = "You must supply a reason a to hide a project!"
      redirect_to chapter_projects_path(@project.chapter_id)
    end
  end

  def unhide
    @project = Project.find(params[:id])
    @project.unhide!
    redirect_to chapter_projects_path(@project.chapter_id, anchor: "project#{@project.id}")
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

  def public_view?
    params[:chapter_id].blank?
  end

  def handle_unpublished_projects
    if public_view? && !current_project.try(:winner?)
      if current_user.logged_in?
        redirect_to chapter_project_path(current_project.chapter, current_project) and return
      else
        render_404 and return
      end
    end
  end

  def find_chapter
    if params[:chapter_id]
      @chapter = Chapter.find(params[:chapter_id])
    end
  end

  def set_time_zone(&block)
    if @chapter
      Time.use_zone(@chapter.time_zone, &block)
    else
      yield
    end
  end
end
