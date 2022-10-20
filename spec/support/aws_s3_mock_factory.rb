class AwsS3MockFactory
  def initialize(shrine_s3)
    @shrine_s3 = shrine_s3
  end

  def client
    @shrine_s3.client
  end

  def create_mock_file(options = {})
    obj = OpenStruct.new(
      key: options[:key] || "#{SecureRandom.uuid}.png",
      content_length: Random.rand(10..50000),
      content_type: options[:content_type] || "image/png",
      last_modified: options[:last_modified] || 1.minute.ago
    )

    client.stub_responses(:head_object, {
                            content_length: obj.content_length,
                            content_type: obj.content_type,
                            last_modified: obj.last_modified
                          })

    @shrine_s3.object(obj.key)
  end
end
