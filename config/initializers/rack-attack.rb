class Rack::Attack
  blacklist_ips = ENV['BLACKLIST_IPS'] ? ENV['BLACKLIST_IPS'].split(/,\s*/) : []

  blacklist("blacklisted ips") do |request|
    blacklist_ips.include? request.ip
  end
end
