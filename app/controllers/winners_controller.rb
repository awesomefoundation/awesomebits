class WinnersController < ApplicationController
  before_filter :must_be_able_to_mark_winner

  def create
    @project = Project.find(params[:project_id])
    response_json = { winner: true, project_id: @project.id }
    response_json[:location] = chapter_project_url(winning_chapter, @project) if winning_chapter != @project.chapter
    @project.declare_winner!(winning_chapter)
    render :json => response_json
  end

  def destroy
    @project = Project.find(params[:project_id])
    @project.revoke_winner!
    render :json => { :winner => false, :project_id => @project.id }
  end

  private

  def winning_chapter
    if params[:chapter_id].present?
      @chapter ||= Chapter.find(params[:chapter_id])
    end
  end

  def current_project
    @current_project ||= Project.find(params[:project_id])
  end

  def must_be_able_to_mark_winner
    unless current_user.admin? || current_user.can_mark_winner?(current_project)
      flash[:notice] = t("flash.permissions.cannot-mark-winner")
      redirect_to submissions_path
    end
  end
end
