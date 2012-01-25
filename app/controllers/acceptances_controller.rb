class AcceptancesController < ApplicationController
  def new
    @invitation = Invitation.find(params[:invitation_id])
  end

  def create
    @invitation = Invitation.find(params[:invitation_id])
    if @invitation.accept(params[:invitation])
      redirect_to chapter_url(@invitation.chapter)
    else
      flash[:notice] = "Could not accept the invitation"
      render :new
    end
  end
end
