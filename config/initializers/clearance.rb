Clearance.configure do |config|
  config.mailer_sender = 'do-not-reply@awesomefoundation.org'
  config.password_strategy = Clearance::PasswordStrategies::SHA1
end
