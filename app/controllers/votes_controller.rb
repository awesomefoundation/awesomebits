class VotesController < ApplicationController
  before_filter :must_be_logged_in

  def create
    @project = Project.find(params[:project_id])
    @user = current_user
    @vote = Vote.new(:user => @user, :project => @project)
    @vote.save
    redirect_to projects_path
  end

  def destroy
    Vote.destroy(params[:id])
    redirect_to projects_path
  end

end
