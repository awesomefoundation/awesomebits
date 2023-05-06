class FinalistsController < ApplicationController
  before_action :must_be_able_to_view_finalists

  around_action :set_time_zone

  include ApplicationHelper

  def index
    @start_date, @end_date = extract_timeframe
    @projects = Project.
                  includes(:chapter).
                  with_votes_for_chapter(current_chapter).
                  during_timeframe(@start_date, @end_date).
                  by_vote_count

    unless params[:past_trustees].present?
      @projects = @projects.with_votes_by_members_of_chapter(current_chapter)
    end

    unless params[:hidden].present?
      @projects = @projects.where(hidden_at: nil)
    end

    unless params[:funded].present?
      @projects = @projects.where(funded_on: nil)
    end
  end

  private

  def current_chapter
    @chapter ||= Chapter.find_by_id(params[:chapter_id])
  end

  def must_be_able_to_view_finalists
    unless current_user.admin? || current_user.can_view_finalists_for?(current_chapter)
      flash[:notice] = t("flash.permissions.cannot-view-finalists")
      redirect_to submissions_path
    end
  end

  def set_time_zone(&block)
    Time.use_zone(current_chapter.time_zone, &block)
  end
end
