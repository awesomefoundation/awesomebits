class ProjectsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:new, :create, :success], if: :embed?

  before_action :require_login, except: [:new, :create, :success]
  before_action :verify_user_can_edit, :only => [:destroy]
  before_action :redirect_to_chapter_or_sign_in, :only => [:index], :if => :chapter_missing?
  before_action :find_chapter

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
        @projects = project_filter.page(params[:page]).result.includes(:users, :photos, :real_photos)
        @comments = Comment.where(project_id: @projects.collect(&:id)).includes(:user, :project).viewable_by(user: current_user, chapter: @chapter).by_date

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
    render_404 and return if embed? && !@chapter

    @project = Project.new(chapter: @chapter)
  end

  def create
    @project = Project.new(create_project_params)

    if SpamChecker::Project.new(@project).spam?
      flash[:notice] = t("flash.applications.error")
      render :new
    elsif @project.save
      redirect_to success_submissions_path({ chapter: @project.chapter, mode: params[:mode] }.reject { |_, v| v.blank? })
    else
      flash.now[:notice] = t("flash.applications.error")
      render :new
    end
  end

  def success
    if params[:chapter]
      @chapter = Chapter.find(params[:chapter].downcase) rescue nil
      @twitter_account = @chapter.twitter_account
    end

    @share_url = root_url
  end

  def show
    @project = Project.find(params[:id])

    @display_project_even_if_hidden = true
    @initial_comments = @project.comments.includes(:user).viewable_by(user: current_user, chapter: @chapter).by_date
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])

    if @project.update(update_project_params)
      redirect_to @project
    else
      render :edit
    end
  end

  def hide
    @project = Project.find(params[:id])
    @display_project_even_if_hidden = (params[:context] == "show")

    if params[:hidden_reason].present?
      @project.hide!(params[:hidden_reason], current_user)
    else
      @error_message = t("flash.projects.hide-reason-required")
    end

    respond_to do |format|
      format.turbo_stream do
        render "hide", locals: { project: @project }
      end

      format.html do
        flash[:notice] = @error_message

        return_to = params[:return_to] ? URI(params[:return_to]) : URI(chapter_projects_path(@project.chapter))
        return_to.fragment = "project#{@project.id}"

        redirect_to return_to.to_s
      end
    end
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

  def embed?
    params[:mode] == "embed"
  end

  def project_params
    [ :name, :title, :url, :email, :phone, :about_me, :about_project, :chapter_id, :extra_question_1, :extra_question_2, :extra_question_3, :extra_answer_1, :extra_answer_2, :extra_answer_3, :photo_order, :rss_feed_url, :use_for_money, photo_ids_to_delete: [], photos_attributes: [:id, :image, :caption, :sort_order, :_destroy] ]
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

  def find_chapter
    if params[:chapter_id]
      @chapter = Chapter.find(params[:chapter_id])
    elsif params[:chapter]
      @chapter = Chapter.friendly.find(params[:chapter].downcase, allow_nil: !embed?)
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
