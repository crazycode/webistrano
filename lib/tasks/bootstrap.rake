namespace :bootstrap do
  
  desc "Bootstraps Data for the Application."
  task :run => :environment do
    raise "Please define a frontman_host_set_name in the Webistrano Configuration." unless WebistranoConfig[:frontman_host_set_name]
    host = Host.find_or_initialize_by_name(WebistranoConfig[:frontman_host_set_name])
    host.save!
    puts "Created host: #{WebistranoConfig[:frontman_host_set_name]}"
  end
  
end