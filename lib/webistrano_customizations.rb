require 'open-uri'
module Webistrano
  class Deployer
    
    def fetch_hosts
      raise "Must set Webistrano Configuration setting: frontman_hosts_endpoint" unless WebistranoConfig[:frontman_hosts_endpoint]
      @_fetch_hosts ||= JSON.parse(open(WebistranoConfig[:frontman_hosts_endpoint]).read)
    end
    
    def set_app_pool_roles(config, role_name)
      # go fetch all the hosts from frontman
      # loop over all hosts and configure each for web, app, and db
      # [{"application_server"=>{"name"=>"test", "default"=>false, "updated_at"=>"2009-11-05T03:05:51Z", "id"=>1, "port"=>"80", "ip"=>"123.123.123.123", "staging"=>false, "active"=>true, "created_at"=>"2009-11-05T03:05:51Z"}}, {"application_server"=>{"name"=>"test2", "default"=>false, "updated_at"=>"2009-11-05T03:11:02Z", "id"=>4, "port"=>"80", "ip"=>"123.123.123.123", "staging"=>false, "active"=>true, "created_at"=>"2009-11-05T03:11:02Z"}}]
      hosts = fetch_hosts
      
      if role_name.to_sym == :db
        # If the role is :db, we only use the first host, and make it a primary db server
        config.role role_name, hosts.first["ip"], {:primary => true}
      else
        hosts.each do |host|
          # TODO: switch to use host instead of ip
          config.role role_name, host["ip"]
        end
      end
    end
    
    # This is an override of the set_stage_roles task, which goes out to
    # the frontman server to find all the active hosts to deploy to.
    # 
    def set_stage_roles(config)
      deployment.deploy_to_roles.each do |r|
        
        # create role attributes hash
        role_attr = r.role_attribute_hash
        
        if r.host.name == WebistranoConfig[:frontman_host_set_name]
          set_app_pool_roles(config, r.name)
        else
          if role_attr.blank?
              config.role r.name, r.hostname_and_port
          else
            config.role r.name, r.hostname_and_port, role_attr
          end
        end
      end
    end
  end
end

