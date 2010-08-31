require File.dirname(__FILE__) + '/../test_helper'

class NotificationTest < ActiveSupport::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
    
    Notification.webistrano_sender_address = "FooBar"
    
    stage = create_new_stage
    role = create_new_role(:stage => stage, :name => 'app')
    assert stage.deployment_possible?, stage.deployment_problems.inspect
    deployment = create_new_deployment(:stage => stage, :task => 'deploy')
    
    @mail = Notification.create_deployment(deployment)
  end

  def test_sender_address
    assert_equal ['FooBar'], @mail.from
  end

  def test_recipient_address
    assert_equal [WebistranoConfig[:mail_recipient]], @mail.to
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/notification/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
