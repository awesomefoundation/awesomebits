class SubdomainConstraint
  def self.matches?(request)
    if ENV['CANONICAL_HOST'].present?
      return false if request.host == ENV['CANONICAL_HOST']
    end

    case request.subdomains.first
    when 'www', '', nil, ENV['SUBDOMAIN']
      false
    else
      true
    end
  end
end
