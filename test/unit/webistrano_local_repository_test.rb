require File.dirname(__FILE__) + '/../test_helper'

class Webistrano::LocalRepositoryTest < ActiveSupport::TestCase

  def setup
    @p = create_new_project
    @s = create_new_stage(:project => @p)
    @repository = @s.configuration_parameters.create(:name => 'repository', :value => 'git@server.com:application.git')
    @scm = @s.configuration_parameters.create(:name => 'scm', :value => 'git')
    @branch = @s.configuration_parameters.create(:name => 'branch', :value => 'master')
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

  def test_branch
    assert_equal 'master', @local_repository.branch
    @local_repository.stubs(:configuration_for).returns(nil)
    assert_equal 'master', @local_repository.branch
    @local_repository.stubs(:configuration_for).returns('new-feature')
    assert_equal 'new-feature', @local_repository.branch
  end

  def test_update_code
    # clone a new repo
    @local_repository.stubs(:repo_exists?).returns(false)
    @local_repository.expects(:fresh_checkout)
    @local_repository.update_code

    @local_repository.stubs(:repo_exists?).returns(true)
    @local_repository.expects(:update_existing_checkout)
    @local_repository.update_code
  end

  def test_update_code_only_git
    @local_repository.stubs(:repo_exists?).returns(false)
    @local_repository.stubs(:scm).returns('svn')
    @local_repository.expects(:fresh_checkout).never
    @local_repository.expects(:update_existing_checkout).never
    assert_nil @local_repository.update_code
  end

  def test_log_with_no_previous_deployment
    @local_repository.stubs(:fetch_log).returns(nil)
    assert_equal 'No commits since last deploy', @local_repository.log
  end

  def test_log_with_previous_deployment
    log_str = <<-EOL
8f15746a4c4c4370cde83088edb3242b746e9fe3 Moved LocalRepository from an AR model to a Webistrano module
76135b3426b811751117c170d091107f918a98b8 Merge branch 'master' of github.com:newsdev/webistrano
1cef534b00e188570ada31dec8dd491e7ade125e add local_repository_dir to test config
EOL
    @local_repository.stubs(:fetch_log).returns(log_str)
    assert_equal log_str, @local_repository.log
  end
end

