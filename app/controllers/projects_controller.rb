class ProjectsController < ApplicationController
  before_action :must_be_logged_in, :except => [:show, :new, :create]
  before_action :verify_user_can_edit, :only => [:destroy]
  before_action :redirect_to_chapter_or_sign_in, :only => [:index], :if => :chapter_missing?
  before_action :handle_unpublished_projects, :only => [:show]
  before_action :find_chapter, :only => [:index, :show]

  around_action :set_time_zone, :only => [:index, :show]

  include ApplicationHelper

  def index
    @start_date, @end_date = extract_timeframe
    @short_listed = params[:short_list]

    project_filter = ProjectFilter.new(@chapter.projects).during(@start_date, @end_date)

    if params[:short_list]
      project_filter.shortlisted_by(current_user)
    end

    if params[:funded]
      project_filter.funded
    end

    @q = params[:q].to_s.strip

    unless @q.blank?
      project_filter.search(@q)
    end

    respond_to do |format|
      format.html do
        @projects = project_filter.page(params[:page]).result
        @comments = Comment.where(project_id: @projects).viewable_by(user: current_user, chapter: @chapter).by_date

        current_user.mark_last_viewed_chapter(params[:chapter_id])
      end

      format.csv do
        if export_all?
          @projects = Project.during_timeframe(@start_date, @end_date)
        else
          @projects = project_filter.result
        end

        headers["Content-Disposition"] = "attachment; filename=#{@chapter.slug}_export.csv"
        render body: Project.csv_export(@projects), content_type: 'text/csv'
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
    @project = Project.new(create_project_params)

    if @project.save
      flash[:thanks] = t("flash.applications.thanks")
      redirect_to root_path
    else
      flash.now[:notice] = t("flash.applications.error")
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
      @display_project_even_if_hidden = true
      @initial_comments = @project.comments.viewable_by(user: current_user, chapter: @chapter).by_date
      must_be_logged_in || render
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])

    if @project.update_attributes(update_project_params)
      redirect_to @project
    else
      render :edit
    end
  end

  def hide
    @project = Project.find(params[:id])

    if params[:hidden_reason].present?
      @project.hide!(params[:hidden_reason], current_user)
    else
      flash[:notice] = t("flash.projects.hide-reason-required")
    end

    return_to = params[:return_to] ? URI(params[:return_to]) : URI(chapter_projects_path(@project.chapter))
    return_to.fragment = "project#{@project.id}"

    redirect_to return_to.to_s
  end

  def unhide
    @project = Project.find(params[:id])
    @project.unhide!

    redirect_to chapter_project_path(@project.chapter, @project)
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    redirect_to submissions_path
  end

  private

  def project_params
    [ :name, :title, :url, :email, :phone, :about_me, :about_project, :chapter_id, :extra_question_1, :extra_question_2, :extra_question_3, :extra_answer_1, :extra_answer_2, :extra_answer_3, :photo_order, :rss_feed_url, :use_for_money, photo_ids_to_delete: [], new_photos: [], new_photo_direct_upload_urls: [] ]
  end

  def create_project_params
    params.require(:project).permit(project_params)
  end

  def update_project_params
    params.require(:project).permit(project_params + [:funded_on, :funded_description])
  end

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
      sign_out
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
        render_404 && return
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
