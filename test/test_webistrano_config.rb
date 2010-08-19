# 
#  Example Webistarno configuration
#  
#  copy this file to config/webistrano.rb and edit
#
WebistranoConfig = {

  # secret password for session HMAC
  :session_secret => 'please choose a long random string, min. 30 characters',

  # Uncomment to use CAS authentication
  # :authentication_method => :cas,
  
  # SMTP settings for outgoing email
  :smtp_delivery_method => :sendmail,
  
  :smtp_settings => {
    #:domain  => "example.com",
    #:user_name  => "username",
    #:password  => "passwd",
    #:authentication  => :login
  },
  
  # Sender address for Webistrano emails
  :webistrano_sender_address => "webistrano@example.com",
  
  # Recipient address for Webistrano e-mails
  :mail_recipient => "team@example.com",
  
  # Sender and recipient for Webistrano exceptions
  :exception_recipients => "team@example.com",
  :exception_sender_address => "webistrano@example.com",

  # Frontman Patch
  # the endpoint that contains the JSON array of hosts that we can deploy to
  :frontman_hosts_endpoint => "http://localhost.localdomain/hosts.json",
  :frontman_host_set_name => "EC2-APP-POOL",
  :default_deployment_shortcuts => []
}
