class AcceptancesController < ApplicationController
  def new
    @invitation = Invitation.find(params[:invitation_id])
  end

  def create
    @invitation = Invitation.find(params[:invitation_id])
    if @invitation.accept(params[:invitation])
      redirect_to chapter_url(@invitation.chapter)
    else
      flash[:notice] = t("flash.acceptances.cannot")
      render :new
    end
  end
end
