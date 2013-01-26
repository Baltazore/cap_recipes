set_default(:nginx_pid) { "/var/run/nginx.pid"}
set_default(:nginx_config) { "/etc/nginx/sites-available/#{application}_#{rails_env}"}

namespace :nginx do
  desc "Setup nginx"
  task :setup do
    template "nginx_#{rails_env}", "/tmp/#{application}_#{rails_env}"
    run "#{sudo} mv -f /tmp/#{application}_#{rails_env} #{nginx_config}"
    run "#{sudo} rm /etc/nginx/sites-enabled/#{nginx_config.split('/').last}"
    run "#{sudo} ln -s #{nginx_config} /etc/nginx/sites-enabled/#{nginx_config.split('/').last}"
    restart
  end
  after "deploy:setup", "nginx:setup"

  %w[start stop restart].each do |command|
    desc "#{command} nginx"
    task command do
      run "#{sudo} /etc/init.d/nginx #{command}"
    end
  end
end
