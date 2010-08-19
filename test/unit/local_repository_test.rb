require File.dirname(__FILE__) + '/../test_helper'

class LocalRepositoryTest < ActiveSupport::TestCase

  def setup
    @p = create_new_project
    @s = create_new_stage(:project => @p)
    @repository = @s.configuration_parameters.create(:name => 'repository', :value => 'git@newsdev.ec2.nytimes.com:moder8.git')
    @scm = @s.configuration_parameters.create(:name => 'scm', :value => 'git')
    @application = @s.configuration_parameters.create(:name => 'application', :value => 'moder8')
    @deploy_via = @s.configuration_parameters.create(:name => 'deploy_via', :value => ':remote_cache')
    @local_repository = LocalRepository.new(:stage => @s)
  end

  def test_repository
    assert_equal 'git@newsdev.ec2.nytimes.com:moder8.git', @local_repository.repository
  end

  def test_scm
    assert_equal 'git', @local_repository.scm
  end

  def test_update_code
    assert @local_repository.update_code
    assert @local_repository.update_code
  end

  def test_update_code_only_git
    @local_repository.stubs(:scm).returns('svn')
    assert_nil @local_repository.update_code
  end

  def test_log_with_no_previous_deployment
    assert_not_nil puts @local_repository.log
  end

  def test_log_with_previous_deployment
    assert_not_nil @local_repository.log
  end
end

