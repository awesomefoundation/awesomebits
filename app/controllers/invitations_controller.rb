class InvitationsController < ApplicationController
  before_filter :must_be_logged_in
  before_filter :must_be_able_to_access_chapter

  def new
    @chapter = Chapter.find(params[:chapter_id])
    @invitation = @chapter.invitations.build
  end

  def create
    @chapter = Chapter.find(params[:chapter_id])
    @invitation = Invitation.new(params[:invitation])
    @invitation.chapter = @chapter
    if @invitation.save
      redirect_to chapter_path(@chapter)
    else
      render :new
    end
  end

  private

  def current_chapter
    @chapter ||= Chapter.find(params[:chapter_id])
  end

  def must_be_able_to_access_chapter
    if !current_user.can_manage_chapter?(current_chapter)
      flash[:notice] = "You cannot invite new trustees for that chapter."
      redirect_to root_path
    end
  end
end
