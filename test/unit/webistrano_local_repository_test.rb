require File.dirname(__FILE__) + '/../test_helper'

class Webistrano::LocalRepositoryTest < ActiveSupport::TestCase

  def setup
    @p = create_new_project
    @s = create_new_stage(:project => @p)
    @repository = @s.configuration_parameters.create(:name => 'repository', :value => 'git@server.com:application.git')
    @scm = @s.configuration_parameters.create(:name => 'scm', :value => 'git')
    @application = @s.configuration_parameters.create(:name => 'application', :value => 'moder8')
    @deploy_via = @s.configuration_parameters.create(:name => 'deploy_via', :value => ':remote_cache')
    @local_repository = Webistrano::LocalRepository.new(@s)
    @local_repository.stubs(:run_command)
  end

  def test_initialization
    # no stage
    assert_raise(ArgumentError){
      local_repo = Webistrano::LocalRepository.new
    }

    # works with a stage specified
    assert_nothing_raised{
      local_repo = Webistrano::LocalRepository.new(@s)
    }
  end

  def test_repository
    assert_equal 'git@server.com:application.git', @local_repository.repository
  end

  def test_scm
    assert_equal 'git', @local_repository.scm
  end

  def test_update_code
    # clone a new repo
    @local_repository.stubs(:repo_exists?).returns(false)
    @local_repository.expects(:git_clone)
    @local_repository.update_code

    @local_repository.stubs(:repo_exists?).returns(true)
    @local_repository.expects(:git_pull)
    @local_repository.update_code
  end

  def test_update_code_only_git
    @local_repository.stubs(:repo_exists?).returns(false)
    @local_repository.stubs(:scm).returns('svn')
    assert_nil @local_repository.update_code
  end

  def test_log_with_no_previous_deployment
    @local_repository.stubs(:run_command).returns(nil)
    assert_not_nil @local_repository.log
  end

  def test_log_with_previous_deployment
    assert_not_nil @local_repository.log
  end
end

