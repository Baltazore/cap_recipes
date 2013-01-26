namespace :foreman do
  %w[start stop].each do |action|
    task action do
      run "#{sudo} #{action} #{foreman_app}"
    end
  end
  task :restart do
    foreman.stop
    foreman.start
  end
  task :prepare_config do
    require "erb"
    procfile_template = File.read(File.expand_path('config/deploy/recipes/templates/procfile.erb'))
    procfile_text = ERB.new(procfile_template).result(binding)
    put procfile_text, "#{current_path}/Procfile"
    run "cd #{current_path} && #{sudo} bundle exec foreman export upstart /etc/init -a #{foreman_app} -u #{user} -p #{thin_base_port} -c 'webserver=1,lesson_server=1,faye=1'"
  end

  before 'foreman:start', 'foreman:prepare_config'
end

