module Webistrano
  class LocalRepository
    attr_accessor :stage

    def initialize(stage)
      @stage = stage
    end

    def project
      stage.project
    end

    def project_configuration
      @project_configuration = project.configuration_parameters
    end

    def project_configuration_for(name)
      param = project_configuration.detect{|cp| cp.name == name }
      param.value if param
    end

    def stage_configuration
      @stage_configuration = stage.configuration_parameters
    end

    def stage_configuration_for(name)
      param = stage_configuration.detect{|cp| cp.name == name }
      param.value if param
    end

    def configuration_for(name)
      stage_configuration_for(name) || project_configuration_for(name)
    end

    def repository
      configuration_for('repository')
    end

    def scm
      configuration_for('scm')
    end

    def application
      configuration_for('application')
    end

    def branch
      configuration_for('branch') || 'master'
    end

    def path
      return if application.nil?
      File.join(WebistranoConfig[:local_repository_dir], application)
    end

    def last_deployed_revision
      if last_deployment = stage.deployments.last
        last_deployment.revision
      end
    end

    def update_existing_checkout
      run_command("cd #{path} && git checkout #{branch} && git pull")
    end

    def fresh_checkout
      run_command("cd #{WebistranoConfig[:local_repository_dir]} && git clone #{repository} #{application}")
    end

    def repo_exists?
      File.directory?(path)
    end

    def update_code
      return unless scm == 'git' && !repository.blank? && !path.blank?

      # application already checked out
      if repo_exists?
        update_existing_checkout
      else
        fresh_checkout
      end
    end

    def fetch_log(since_until = '')
      run_command("cd #{path} && git checkout #{branch} && git log --format=oneline #{since_until}")
    end

    def log
      output = last_deployed_revision ? fetch_log("#{last_deployed_revision}..HEAD") : fetch_log
      output.blank? ? "No commits since last deploy" : output
    end

    # run the command, returning the result on success or raising an exception
    def run_command(command)
      result = `#{command} 2>&1`
      if $?.success?
        result
      else
        raise Exception.new(result)
      end
    end
  end
end
