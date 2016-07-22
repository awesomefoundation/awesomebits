class SubdomainConstraint
  def self.matches?(request)
    case request.subdomains.first
    when 'www', '', nil, 'staging'
      false
    else
      true
    end
  end
end
