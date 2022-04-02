class VotesController < ApplicationController
  before_action :must_be_logged_in

  def create
    @project = Project.find(params[:project_id])
    @user = current_user
    @vote = Vote.new(user: @user, project: @project, chapter_id: params[:chapter_id])
    if @vote.save
      render json: {shortlisted: true, project_id: @project.id, chapter_id: params[:chapter_id]}
    else
      render :json => {:message => t("flash.votes.already-voted")}, :status => 400
    end
  end

  def destroy
    @project = Project.find(params[:project_id])
    @user = current_user
    if @vote = @user.votes.find_by(project: @project)
      @vote.destroy
      render json: {shortlisted: false, project_id: @project.id, chapter_id: params[:chapter_id]}
    else
      render :json => {:message => t("flash.votes.already-deleted")}, :status => 400
    end
  end
end
