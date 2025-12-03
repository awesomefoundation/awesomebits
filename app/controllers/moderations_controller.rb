class ModerationsController < ApplicationController
  CONFIRMATION_EMAIL_DELAY_SECONDS = 10

  before_action :require_login
  before_action :find_chapter, only: [:index]
  before_action :find_project_and_chapter, only: [:confirm_spam, :confirm_legit, :undo]
  before_action :ensure_user_can_moderate

  def index
    @projects = projects_scope(all: params[:filter] == "all")
    @moderation_count = @projects.count

    @comments = Comment.where(project: @projects).includes(:user, :project).viewable_by(user: current_user, chapter: @chapter).by_date
    @projects = @projects.includes(:users, :project_moderation).preload(:photos, :real_photos).order(created_at: :desc).page(params[:page])
  end

  def confirm_spam
    @project.project_moderation&.mark_confirmed_spam!(current_user)
    render partial: "projects/moderation", locals: {project: @project}
  end

  def confirm_legit
    @project.project_moderation&.mark_confirmed_legit!(current_user)

    # Send the application confirmation email with a delay to allow for the undo
    ProjectMailerJob.perform_in(CONFIRMATION_EMAIL_DELAY_SECONDS, @project.id)

    render partial: "projects/moderation", locals: {project: @project}
  end

  def undo
    if @project.project_moderation
      @project.project_moderation.update!(
        status: :suspected,
        reviewed_by: nil,
        reviewed_at: nil
      )
    end
    render partial: "projects/moderation", locals: {project: @project}
  end

  private

  def projects_scope(all: false)
    if @chapter
      all ? @chapter.projects.joins(:project_moderation) : @chapter.projects_pending_moderation
    elsif current_user.admin?
      all ? Project.joins(:project_moderation) : Project.joins(:project_moderation).merge(ProjectModeration.pending)
    else
      Project.none
    end
  end

  def find_chapter
    @chapter = Chapter.friendly.find(params[:chapter_id]) if params[:chapter_id]
  end

  def ensure_user_can_moderate
    return if current_user.can_moderate_for?(@chapter)

    render_404
  end

  def find_project_and_chapter
    @project = Project.find(params[:project_id])
    @chapter = @project.chapter
  end
end
