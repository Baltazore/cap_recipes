set_default(:thin_conf_path) { "/etc/thin/#{application}_#{rails_env}_thin.conf" }
namespace :thin do
  desc 'Setup thin'
  task :setup do
    template 'thin.conf', "/tmp/#{application}_#{rails_env}_thin.conf"
    run "#{sudo} mkdir -p /etc/thin"
    run "#{sudo} mv /tmp/#{application}_#{rails_env}_thin.conf #{thin_conf_path}"
  end
  after 'deploy:setup', 'thin:setup'

  %w[start stop restart].each do |command|
    desc "#{command} thin"
    task command do
      run "cd #{current_path} && bundle exec thin #{command} -C #{thin_conf_path} --socket tmp/thin.sock"
    end
  end
  after 'deploy:restart', 'thin:restart'
end
