set_default(:private_pub_server) { "localhost" }
set_default(:private_pub_host) { "0.0.0.0" }
set_default(:private_pub_port) { "9292" }
set_default(:private_pub_path) { "/faye" }
set_default(:private_pub_user) { user }
set_default(:private_pub_group) { user }
set_default(:private_pub_pid) { "#{shared_path}/pids/private_pub.pid" }

namespace :private_pub do
  desc "Sets up private pub configuration for the server"
  task :setup do
    run "mkdir -p #{shared_path}/config"

    template "private_pub.yml", "#{shared_path}/config/private_pub.yml"
    template "private_pub_thin.yml", "#{shared_path}/config/private_pub_thin.yml"
  end
  after "deploy:setup", "private_pub:setup"

  desc "Start private_pub server"
  task :start, :roles => :private_pub do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} nohup bundle exec thin -C #{current_path}/config/private_pub_thin.yml start"
  end

  desc "Stop private_pub server"
  task :stop, :roles => :private_pub  do
    run "cd #{current_path}; if [ -f #{private_pub_pid} ] && [ -e /proc/$(cat #{private_pub_pid}) ]; then kill -9 `cat #{private_pub_pid}`; fi"
  end

  desc "Restart private_pub server"
  task :restart, :roles => :private_pub do
    find_and_execute_task("private_pub:stop")
    find_and_execute_task("private_pub:start")
  end
  after "deploy:restart", "private_pub:restart"


  desc "Symlinks the config for private pub server"
  task :symlink do
    run "rm -f #{latest_release}/config/private_pub_thin.yml"
    run "ln -s #{shared_path}/config/private_pub_thin.yml #{latest_release}/config/private_pub_thin.yml"

    run "rm -f #{latest_release}/config/private_pub.yml"
    run "ln -s #{shared_path}/config/private_pub.yml #{latest_release}/config/private_pub.yml"
  end
  after "deploy:finalize_update", "private_pub:symlink"
end