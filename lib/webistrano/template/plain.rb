module Webistrano
  module Template
    module Plain
      CONFIG = {
        :application => 'your_app_name',
        :scm => 'subversion',
        :deploy_via => ':checkout',
        :scm_username => 'webistrano',
        :scm_password => 'webist4no',
        :user => 'root',
        :web_user => 'www-data',
        :writable_directories => 'tmp',
        :use_sudo => 'true',
        :ssh_keys => '/var/local/keys/id-server-farm-test',
        :repository => 'https://newsdev.ec2.nytimes.com/svn/projects/your-app-name',
        :target_rails_env => 'production'
      }.freeze
      
      DESC = <<-'EOS'
        Plain project type: specific deploy configs should be added as recipies to each stage.
      EOS
      
      TASKS = ""
    end
  end
end