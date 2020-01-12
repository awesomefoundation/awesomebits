class WinnersController < ApplicationController
  before_action :must_be_able_to_mark_winner

  def create
    @project = Project.find(params[:project_id])
    response_json = { winner: true, project_id: @project.id }
    response_json[:location] = chapter_project_url(winning_chapter, @project) if winning_chapter != @project.chapter
    @project.declare_winner!(winning_chapter)
    render :json => response_json
  end

  def edit
    @project = FundedProject.find(params[:project_id])
  end

  def update
    @project = FundedProject.find(params[:project_id])
    @project.attributes = winner_params

    if @project.save
      redirect_to params[:return_to] || chapter_project_path(@project.chapter, @project)
    else
      render action: "edit"
    end
  end

  def destroy
    @project = Project.find(params[:project_id])
    @project.revoke_winner!
    render :json => { :winner => false, :project_id => @project.id }
  end

  private

  def winner_params
    permitted = [:funded_on, :title, :name, :url, :rss_feed_url, :funded_description, photo_ids_to_delete: [], new_photos: [], new_photo_direct_upload_urls: [] ]
    permitted << :chapter_id if helpers.winnable_chapters_for(@project).count > 1

    params.require(:project).permit(permitted)
  end

  def winning_chapter
    if params[:chapter_id].present?
      @chapter ||= Chapter.find(params[:chapter_id])
    end
  end

  def current_project
    @current_project ||= Project.find(params[:project_id])
  end

  def must_be_able_to_mark_winner
    unless current_user.admin? || (current_user.can_mark_winner?(current_project) && current_user.chapters.include?(winning_chapter))
      flash[:notice] = t("flash.permissions.cannot-mark-winner")
      render :json => { :location => chapter_projects_path(current_project.chapter) }
    end
  end
end
