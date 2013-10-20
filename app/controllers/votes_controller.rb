class VotesController < ApplicationController
  before_filter :must_be_logged_in

  def create
    @project = Project.find(params[:project_id])
    @user = current_user
    @vote = Vote.new(user: @user, project: @project)
    if @vote.save
      render json: {shortlisted: true, project_id: @project.id}
    else
      render json: {message: t("flash.votes.already-voted")}, status: 400
    end
  end

  def destroy
    @project = Project.find(params[:project_id])
    @user = current_user
    if @vote = Vote.find_by_project_id_and_user_id(@project, @user)
      @vote.destroy
      render json: {shortedlisted: false, project_id: @project.id}
    else
      render json: {message: t("flash.votes.already-deleted")}, status: 400
    end
  end

end
