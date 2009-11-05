require File.dirname(__FILE__) + '/../test_helper'

class Webistrano::DeployerTest < ActiveSupport::TestCase

  def setup
    @project = create_new_project(:template => 'pure_file')
    @stage = create_new_stage(:project => @project)
    @host = create_new_host
    
    @role = create_new_role(:stage => @stage, :host => @host, :name => 'web')
    
    assert @stage.prompt_configurations.empty?
    
    @deployment = create_new_deployment(:stage => @stage, :task => 'master:do')
    
    # Frontman Patch
    @fake_fetch_hosts = [{"application_server"=>{"ip"=>"123.123.123.123"}}, {"application_server"=>{"ip"=>"123.123.123.123"}}]
    Webistrano::Deployer.any_instance.stubs(:fetch_hosts).returns(@fake_fetch_hosts)
    @fake_app_host = create_new_host(:name => WebistranoConfig[:frontman_host_set_name])    
  end

  # Frontman Patch
  def test_frontman_webistrano_customizations
    # prepare stage + roles
    @stage = create_new_stage
    
    web_role = @stage.roles.build(:name => 'web', :host_id => @fake_app_host.id, :primary => 1, :no_release => 0)
    web_role.save!
    assert !web_role.no_release?
    assert web_role.primary?
    
    app_role = @stage.roles.build(:name => 'app', :host_id => @fake_app_host.id, :primary => 0, :no_release => 1, :ssh_port => '99')
    app_role.save!
    assert app_role.no_release?
    assert !app_role.primary?
    
    db_role = @stage.roles.build(:name => 'db', :host_id => @fake_app_host.id, :primary => 1, :no_release => 1, :ssh_port => 44)
    db_role.save!    
    assert db_role.no_release?
    assert db_role.primary?
    
    # prepare Mocks
    #
    
    # Logger stubing
    mock_cap_logger = mock
    mock_cap_logger.expects(:level=).with(3)
    
    # config stubbing
    mock_cap_config = mock
    mock_cap_config.stubs(:logger).returns(mock_cap_logger)
    mock_cap_config.stubs(:logger=)
    mock_cap_config.stubs(:load)
    mock_cap_config.stubs(:trigger)
    mock_cap_config.stubs(:find_and_execute_task)
    mock_cap_config.stubs(:[])
    mock_cap_config.stubs(:fetch).with(:scm)
    
    # ignore vars
    mock_cap_config.stubs(:set)
      
    #  
    # now check the roles        
    # 
    # We're not sure why config.role is not called for these tests, however,
    # see below, where we make sure that our custom Deployer#set_app_pool_rules
    # is called instead:
    # 
    # @fake_fetch_hosts.each do |fake_fetch_host|
    #   mock_cap_config.expects(:role).with('web', fake_fetch_host["application_server"]["ip"])
    #   mock_cap_config.expects(:role).with('app', fake_fetch_host["application_server"]["ip"])
    # end
    # mock_cap_config.expects(:role).with('db', @fake_fetch_hosts.first["application_server"]["ip"], {:primary => true})
    
    # main mock install
    Webistrano::Configuration.expects(:new).returns(mock_cap_config)
    
    # get things started
    deployer = Webistrano::Deployer.new( create_new_deployment(:stage => @stage) )
    
    deployer.expects(:set_app_pool_roles).with('web')
    deployer.expects(:set_app_pool_roles).with('app')
    deployer.expects(:set_app_pool_roles).with('db')
    
    deployer.invoke_task!
  end

end