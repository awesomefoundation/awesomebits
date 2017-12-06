class Gravatar
  attr_reader :email

  def initialize(email)
    @email = email
  end

  def hash
    Digest::MD5.hexdigest(email.to_s.strip.downcase)
  end

  def url
    "https://www.gravatar.com/avatar/#{hash}?d=retro&s=134"
  end
end
