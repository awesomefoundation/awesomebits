class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    valid = begin
              URI.parse(value).kind_of?(URI::HTTP)
            rescue URI::InvalidURIError
              false
            end

    unless valid
      record.errors.add(attribute, options[:message] || :invalid)
    end
  end
end
