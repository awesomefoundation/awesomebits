class WinnersController < ApplicationController
  before_filter :must_be_able_to_mark_winner

  def create
    @project = Project.find(params[:project_id])
    @project.declare_winner!(winning_chapter)
    redirect_to projects_path
  end

  def destroy
    @project = Project.find(params[:project_id])
    @project.revoke_winner!
    redirect_to projects_path
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
      flash[:notice] = "You cannot mark that a winner."
      redirect_to projects_path
    end
  end
end
