class WinnersController < ApplicationController
  before_action :must_be_able_to_mark_winner, only: [:create, :update, :destroy]

  def create
    @project = Project.find(params[:project_id])
    response_json = { winner: true, project_id: @project.id }
    response_json[:location] = chapter_project_url(winning_chapter, @project) if winning_chapter != @project.chapter
    @project.declare_winner!(winning_chapter)
    render :json => response_json
  end

  def edit
    @project = FundedProject.find(params[:project_id])
    @project.funded_description = @project.about_project if @project.funded_description.blank?
  end

  def update
    @project = FundedProject.find(params[:project_id])
    @project.attributes = winner_params

    if @project.save
      if @project.chapter_id_previously_changed? || params[:return_to].blank?
        redirect_to chapter_project_path(@project.chapter, @project)
      else
        redirect_to params[:return_to]
      end
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
    permitted << :chapter_id if current_project.in_any_chapter? || current_user.admin?

    params.require(:project).permit(permitted)
  end

  def winning_chapter
    if params[:chapter_id].present?
      @chapter ||= Chapter.find(params[:chapter_id])
    elsif params.dig(:project, :chapter_id).present?
      @chapter ||= Chapter.find(params[:project][:chapter_id])
    else
      @chapter ||= current_project.chapter
    end
  end

  def current_project
    @current_project ||= Project.find(params[:project_id])
  end

  def must_be_able_to_mark_winner
    unless current_user.can_mark_winner?(current_project) && current_user.chapters.include?(winning_chapter)
      flash[:notice] = t("flash.permissions.cannot-mark-winner")
      redirect_location = chapter_projects_path(current_project.chapter)

      respond_to do |format|
        format.js { render json: { :location => redirect_location } }
        format.html { redirect_to redirect_location and return }
      end
    end
  end
end
