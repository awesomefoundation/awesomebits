class FinalistsController < ApplicationController
  before_filter :must_be_able_to_view_finalists

  include ApplicationHelper

  def index
    @start_date, @end_date = extract_timeframe
    @projects = Project.
                  voted_for_by_members_of(current_chapter).
                  during_timeframe(@start_date, @end_date).
                  by_vote_count
  end

  private

  def current_chapter
    @chapter ||= Chapter.find_by_id(params[:chapter_id])
  end

  def must_be_able_to_view_finalists
    unless current_user.admin? || current_user.can_view_finalists_for?(current_chapter)
      flash[:notice] = t("flash.permissions.cannot-view-finalists")
      redirect_to projects_path
    end
  end
end
