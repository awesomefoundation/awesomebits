class InvitationsController < ApplicationController
  def new
    @chapter = Chapter.find(params[:chapter_id])
    @invitation = @chapter.invitations.build
  end

  def create
    @chapter = Chapter.find(params[:chapter_id])
    @invitation = Invitation.new(params)
    if @invitation.save
      redirect_to chapter_url(@chapter)
    else
      render :new
    end
  end
end
