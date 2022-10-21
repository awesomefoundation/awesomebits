Clearance.configure do |config|
  config.allow_sign_up = false
  config.password_strategy = Clearance::PasswordStrategies::SHA1
  config.mailer_sender = 'do-not-reply@awesomefoundation.org'
  config.rotate_csrf_on_sign_in = true
  config.routes = false
end
