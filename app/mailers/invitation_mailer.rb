class InvitationMailer < ActionMailer::Base
  default :from => DO_NOT_REPLY

  def invite_trustee(invitation)
    @invitation = invitation
    mail(:to => invitation.email,
         :subject => "[Awesome] #{t('emails.invitation.subject', :name => invitation.chapter.name)}")
  end

  def welcome_trustee(invitation)
    @invitation = invitation
    mail(:to => invitation.email,
         :subject => "[Awesome] #{t('emails.welcome.subject', :name => invitation.chapter.name)}")
  end
end
