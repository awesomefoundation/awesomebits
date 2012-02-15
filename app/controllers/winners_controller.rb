class WinnersController < ApplicationController
  before_filter :must_be_able_to_mark_winner

  def create
    @project = Project.find(params[:project_id])
    if @project.declare_winner!
      @project.deliver_winning_email
    end
    redirect_to projects_path
  end

  def destroy
    @project = Project.find(params[:project_id])
    @project.revoke_winner!
    redirect_to projects_path
  end

  private

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
