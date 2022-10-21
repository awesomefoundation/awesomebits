class Rack::Attack
  blocklist_ips = ENV['BLOCKLIST_IPS'] ? ENV['BLOCKLIST_IPS'].split(/,\s*/) : []

  blocklist("blacklisted ips") do |request|
    blocklist_ips.include? request.ip
  end
end
