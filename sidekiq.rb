namespace :my_sidekiq do
  task :prepare_config do
    require "erb"
    template = File.read(File.expand_path('config/deploy/recipes/templates/sidekiq.yml.erb'))
    text = ERB.new(template).result(binding)
    run "rm #{current_path}/config/sidekiq.yml"
    put text, "#{current_path}/config/sidekiq.yml"
  end
  before 'sidekiq:start', 'my_sidekiq:prepare_config'
end
