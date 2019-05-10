class InvitationsController < ApplicationController
  before_action :must_be_logged_in
  before_action :must_be_able_to_invite

  def new
    @invitation = Invitation.new
  end

  def create
    @invitation = find_invitation(invitation_params)
    @invitation.inviter = current_user
    if @invitation.save
      @invitation.send_invitation
      flash[:notice] = t(".invitation_sent", email: @invitation.email)
      redirect_to submissions_path
    else
      render :new
    end
  end

  private

  def invitation_params
    params.require(:invitation).permit(:email, :first_name, :last_name, :chapter_id, :role_name)
  end

  def find_invitation(attributes)
    invitation = Invitation.where(:email => attributes[:email]).
                            where(:chapter_id => attributes[:chapter_id]).
                            first
    invitation ||= Invitation.new
    invitation.attributes = attributes
    invitation
  end

  def must_be_able_to_invite
    unless current_user.can_invite?
      flash[:notice] = t("flash.permissions.cannot-invite")
      redirect_to root_path
    end
  end
end
