class AcceptancesController < ApplicationController
  def new
    @invitation = Invitation.find(params[:invitation_id])
  end

  def create
    @invitation = Invitation.find(params[:invitation_id])
    if @invitation.accept(params[:invitation])
      flash[:notice] = t(".success")
      redirect_to sign_in_path
    else
      flash[:notice] = t("flash.acceptances.cannot")
      render :new
    end
  end
end
