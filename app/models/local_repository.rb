#+--------------+--------------+------+-----+---------+----------------+
#  | Field        | Type         | Null | Key | Default | Extra          |
#  +--------------+--------------+------+-----+---------+----------------+
#  | id           | int(11)      | NO   | PRI | NULL    | auto_increment |
#  | stage_id     | int(11)      | YES  |     | NULL    |                |
#  | created_at   | datetime     | YES  |     | NULL    |                |
#  | updated_at   | datetime     | YES  |     | NULL    |                |
#  +--------------+--------------+------+-----+---------+----------------+

class LocalRepository < ActiveRecord::Base
  belongs_to :stage

  def repository
    repo_config = stage.configuration_parameters.detect{|cp| cp.name == 'repository' }
    repo_config.value if repo_config
  end

  def scm
    scm_config = stage.configuration_parameters.detect{|cp| cp.name == 'scm' }
    scm_config.value if scm_config
  end

  def application
    scm_config = stage.configuration_parameters.detect{|cp| cp.name == 'application' } || stage.project.configuration_parameters.detect{|cp| cp.name == 'application'}
    scm_config.value if scm_config
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

  def update_code
    return unless scm == 'git' && !repository.blank? && !path.blank?

    # application already checked out
    if File.directory?(path)
      `cd #{path} && git pull`
    else
      `cd #{WebistranoConfig[:local_repository_dir]} && git clone #{repository} #{application}`
    end
  end

  def log
    output = if last_deployed_revision
      `cd #{path} && git log --format=oneline #{last_deployed_revision}..HEAD`
    else
      `cd #{path} && git log --format=oneline`
    end
    output.blank? ? "No commits since last deploy" : output
  end
end
