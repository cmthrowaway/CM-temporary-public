require 'tls_smtp'

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :tls => true,
  :address => "smtp.gmail.com",
  :port => 587,
  :domain => "www.citizensmarket.org",
  :authentication => :login,
  :enable_starttls_auto => true,
  :user_name => "support@citizensmarket.org",
  :password => "Gcm248248"
}