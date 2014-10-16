class ProjectMailerJob
  include SuckerPunch::Job

  def perform(project)
    ActiveRecord::Base.connection_pool.with_connection do
      project.mailer.new_application(project).deliver
    end
  end
end
