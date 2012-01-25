class InvitationsController < ApplicationController
  before_filter :must_be_admin

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
end
