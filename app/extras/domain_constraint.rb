class DomainConstraint
  def self.matches?(request)
    ENV['CANONICAL_HOST'].present? && request.host != ENV['CANONICAL_HOST']
  end
end
