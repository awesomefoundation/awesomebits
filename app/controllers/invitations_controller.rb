class InvitationsController < ApplicationController
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

  def must_be_able_to_access_chapter
    if current_user.try(:can_manage_chapter?, Chapter.find(params[:chapter_id])).nil?
      redirect_to root_path
    end
  end
end
