class UrlNormalizer
  def initialize(*url_fields)
    @url_fields = url_fields
  end

  def before_validation(record)
    @url_fields.each do |url_field|
      url = record[url_field]

      if url.present? && ! url.match(/:\/\//) && ! url.match(/^mailto:/)
        record[url_field] = "http://#{url}"
      end
    end
  end
end
