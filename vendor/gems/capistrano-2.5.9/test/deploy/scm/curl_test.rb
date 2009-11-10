require "utils"
require 'capistrano/recipes/deploy/scm/curl'

class DeploySCMCurlTest < Test::Unit::TestCase
  class TestSCM < Capistrano::Deploy::SCM::Curl
    default_command "curl"
  end

  def setup
    @config = { :urls => "http://test.example.com/some-file.txt" }
    def @config.exists?(name); key?(name); end

    @source = TestSCM.new(@config)
    FileUtils.stubs(:mkdir)
  end

  def test_checkout_creates_dest_directory
    test_dest = '/tmp/test-dest'
    FileUtils.expects(:mkdir).with(test_dest)
    @source.checkout('HEAD', test_dest)
  end

  def test_checkout_with_one_url
    resulting_cmd = @source.checkout('HEAD', '/tmp/test-dest')
    expected_cmd = 'curl -# --output /tmp/test-dest/some-file.txt http://test.example.com/some-file.txt;'
    assert_equal expected_cmd, resulting_cmd
  end

  def test_checkout_with_multiple_urls
    @config = {:urls => 'http://test.example.com/file1.txt,http://test.example.com/file2.txt'}
    @source = TestSCM.new(@config)
    
    expected_cmd1 = 'curl -# --output /tmp/test-dest/file1.txt http://test.example.com/file1.txt;'
    expected_cmd2 = 'curl -# --output /tmp/test-dest/file2.txt http://test.example.com/file2.txt;'
    
    resulting_cmd = @source.checkout('HEAD', '/tmp/test-dest')
    assert_match expected_cmd1, resulting_cmd
    assert_match expected_cmd2, resulting_cmd
  end
  
  def test_execption_raised_on_no_file_url
    @config = {:urls => 'http://test.example.com/'}
    @source = TestSCM.new(@config)
    assert_raises(ArgumentError) { @source.checkout('HEAD','/tmp/test-dest') }
    
    
    @config = {:urls => 'http://test.example.com'}
    @source = TestSCM.new(@config)
    assert_raises(ArgumentError) { @source.checkout('HEAD','/tmp/test-dest') }
  end

  def test_query_revision
    revision = @source.query_revision('HEAD')
    assert_in_delta Time.now.to_i, revision, 1
  end
  
  def test_next_revision
    revision = @source.query_revision('HEAD')
    assert_in_delta Time.now.to_i + 1, revision, 1
  end
end
