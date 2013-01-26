set_default(:solr_host) { "localhost" }
set_default(:solr_port) { 8982 }
set_default(:solr_path) { "/solr" }
set_default(:solr_log_level) { "INFO" }

namespace :solr do
  desc "Generate the sunspot.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "sunspot.yml", "#{shared_path}/config/sunspot.yml"
  end
  after "deploy:setup", "solr:setup"

  desc "Symlink the sunspot.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/sunspot.yml #{latest_release}/config/sunspot.yml"
  end
  after "deploy:finalize_update", "solr:symlink"

  %w[start stop restart].each do |command|
    desc "#{command} solr"
    task command, roles: :db do
      run "#{sudo} /etc/init.d/tomcat6 #{command}"
    end
  end

  task :reindex, :roles => :db do
    roles[:db].servers.each do |server|
      run "cd #{current_path} && rake sunspot:reindex RAILS_ENV=#{rails_env}"
    end
  end
end