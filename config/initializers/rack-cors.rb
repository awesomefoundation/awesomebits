# This is needed to ensure that fonts (and other assets) that are served
# directly by the Rails app on Heroku and then served via a CDN (Cloudfront)
# will serve the correct headers and will let the browsers load them properly
# https://devcenter.heroku.com/articles/using-amazon-cloudfront-cdn#cors
Rails.configuration.middleware.insert_before 0, Rack::Cors do
  allow do
    if ENV['CANONICAL_HOST'].present?
      origins "https://#{ENV['CANONICAL_HOST']}",
              "http://#{ENV['CANONICAL_HOST']}"
    else
      origins "https://#{ ENV['SUBDOMAIN'] || "www" }.awesomefoundation.org",
              "http://#{ ENV['SUBDOMAIN'] || "www" }.awesomefoundation.org"
    end

    resource '/assets/*', headers: :any, methods: [:get, :post, :options]
  end
end
