namespace :logrotate do
  desc 'Setup logrotate on server'
  task :setup, roles: :web do
    file_name = "logrotate_#{application}_#{stage}_#{rails_env}".gsub(/[^\w]/, '_')
    template 'logrotate', "/tmp/#{file_name}"
    run "#{sudo} mv -f /tmp/#{file_name} /etc/logrotate.d/#{file_name}"
  end
end
