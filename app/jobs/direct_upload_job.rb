class DirectUploadJob
  include SuckerPunch::Job

  def perform(target)
    ActiveRecord::Base.connection_pool.with_connection do
      target.transfer_from_direct_upload
    end
  end
end
