class SubdomainConstraint
  def self.matches?(request)
    case request.subdomains.first
    when 'www', '', nil, ENV['SUBDOMAIN']
      false
    else
      true
    end
  end
end
