class ProjectMailer < ActionMailer::Base
  default :from => DO_NOT_REPLY

  def new_application(project)
    @project = project
    mail(:to => project.email,
         :subject => "[Awesome] #{t("emails.application.subject")}")
  end
end
