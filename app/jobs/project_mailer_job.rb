class ProjectMailerJob
  include SuckerPunch::Job

  def perform(project_id)
    ActiveRecord::Base.connection_pool.with_connection do
      project = Project.find_by(id: project_id)
      return unless project

      if project.not_pending_moderation?
        project.mailer.new_application(project).deliver_now
      else
        Rails.logger.info "SUSPECTED SPAM: Project #{project.id} pending moderation - new_application mail not sent"
      end
    end
  end
end
