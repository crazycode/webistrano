module Webistrano
  module Template
    module Plain
      CONFIG = {
        :application => 'your_app_name',
        :scm => 'subversion',
        :deploy_via => ':checkout',
        :scm_username => 'webistrano',
        :scm_password => 'webistr4no',
        :user => 'root',
        :web_user => 'www-data',
        :writable_directories => 'tmp',
        :use_sudo => 'true',
        :ssh_keys => '/var/local/keys/id-test-server-farm',
        :repository => 'https://newsdev.ec2.nytimes.com/svn/projects/your-app-name',
        :target_rails_env => 'production'
      }.freeze
      
      DESC = <<-'EOS'
        Plain project type: specific deploy configs should be added as recipies to each stage.
      EOS
      
      TASKS =  <<-'EOS'
        # allocate a pty by default as some systems have problems without
        default_run_options[:pty] = true
      
        # set Net::SSH ssh options through normal variables
        # at the moment only one SSH key is supported as arrays are not
        # parsed correctly by Webistrano::Deployer.type_cast (they end up as strings)
        [:ssh_port, :ssh_keys].each do |ssh_opt|
          if exists? ssh_opt
            logger.important("SSH options: setting #{ssh_opt} to: #{fetch(ssh_opt)}")
            ssh_options[ssh_opt.to_s.gsub(/ssh_/, '').to_sym] = fetch(ssh_opt)
          end
        end
      EOS
    end
  end
end