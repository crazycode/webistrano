class Notification < ActionMailer::Base
  
  @@webistrano_sender_address = 'Webistrano'
  
  def self.webistrano_sender_address=(val)
    @@webistrano_sender_address = val
  end

  def deployment(deployment)
    @subject    = "[#{deployment.stage.project.name}] #{deployment.stage.name.downcase} #{deployment.task} #{deployment.status if deployment.status != 'success'}"
    @body       = {:deployment => deployment}
    @recipients = WebistranoConfig[:mail_recipient]
    @from       = @@webistrano_sender_address
    @sent_on    = Time.now
    @headers    = {}
  end
end
