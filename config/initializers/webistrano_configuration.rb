if WebistranoConfig[:authentication_method] == :cas
  cas_options = YAML::load_file(RAILS_ROOT+'/config/cas.yml')
  CASClient::Frameworks::Rails::Filter.configure(cas_options[RAILS_ENV])
end

WEBISTRANO_VERSION = '1.5'

unless Rails.env.test? # don't configure SMTP in test
  ActionMailer::Base.delivery_method = WebistranoConfig[:smtp_delivery_method] 
  ActionMailer::Base.smtp_settings = WebistranoConfig[:smtp_settings] 
end

Notification.webistrano_sender_address = WebistranoConfig[:webistrano_sender_address]

ExceptionNotifier.exception_recipients = WebistranoConfig[:exception_recipients] 
ExceptionNotifier.sender_address = WebistranoConfig[:exception_sender_address] 
