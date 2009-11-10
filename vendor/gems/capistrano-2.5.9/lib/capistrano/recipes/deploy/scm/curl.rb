require 'capistrano/recipes/deploy/scm/base'
require 'fileutils'

module Capistrano
  module Deploy
    module SCM

      # Allows capistrano to grab files for deployment using a series of simple curl commands.
      # Define the list of files to be curled by setting the :urls variable to a comma-delimited list
      # of URLs.  Note that these URLs must include file names; paths such as "http://example.com/" with
      # implicit file names will raise an exception. 
      class Curl < Base
        # Sets the default command name.
        # Override this by setting the :scm_command variable if curl is not available in the default path.
        default_command "curl"

        # Stub implementation for curl.
        def head
          "HEAD"
        end

        # Returns a command that will curl :urls to the
        # given destination.
        def checkout(revision, destination)
          FileUtils.mkdir(destination)
          curl_cmd(destination)
        end

        # Returns a command that will curl :urls to the
        # given destination.
        def sync(revision, destination)
          FileUtils.mkdir(destination)
          curl_cmd(destination)
        end

        # Returns a command that will curl :urls to the
        # given destination.
        def export(revision, destination)
          FileUtils.mkdir(destination)
          curl_cmd(destination)
        end

        # For curl-based deploys, REVISION is set to the current UNIX timestamp
        def query_revision(revision)
          Time.now.to_i
        end

        # The next revision for curl-based deploys is the current UNIX timestamp + 1
        def next_revision(revision)
          Time.now.to_i + 1
        end
        
        private
        def curl_cmd(destination)
          cmds = configuration[:urls].split(',').collect do |url|
            url.strip!
            file_name = (url.match(/\w+:\/\/.+\/(.+)$/) || [])[1] # look for the trailing filename fragment
            raise ArgumentError, "You must specify a URL path that includes a file name. #{url} does not appear to contain a full file name." if file_name.nil?

            "curl -# --output #{destination}/#{file_name} #{url}"
          end
          return cmds.map {|c| c + ';'}.join(' ') # Ensure that every command ends in a ';'
        end

      end

    end
  end
end
