set_default(:mysql_host, "127.0.0.1")
set_default(:mysql_user) { "root" }
set_default(:mysql_password) { Capistrano::CLI.password_prompt "mysql Password: " }
set_default(:mysql_database) { "matraskin_#{rails_env}" }
set_default(:mysql_pid) { "/var/run/mysqld/mysqld.pid" }
set_default(:mysql_daemon) { "/etc/init.d/mysql" }

namespace :mysql do
  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "mysql.yml", "#{shared_path}/config/database.yml"
  end
  after "deploy:setup", "mysql:setup"

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "mysql:symlink"
end
