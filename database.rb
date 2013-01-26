namespace :database do
  require 'yaml'

  def mysql_config
    YAML::load(capture("cat #{current_path}/config/database.yml"))[rails_env]
  end

  def backup_name
    @backup_name ||= (backup rescue nil) || "#{mysql_config["database"]}_backup_#{Time.now.strftime("%d-%m-%Y")}"
  end

  def backup_path
    "#{current_path}/tmp/#{backup_name}.sql"
  end

  task :pull, :roles => :db do
    unless remote_file_exists?(backup_path)
      run "cd #{current_path} && mysqldump -u #{mysql_config['username']} -p#{mysql_config['password']} #{mysql_config['database']} > #{backup_path}"
    end

    run "cd #{current_path}/tmp && tar -zcf #{backup_name}.sql.tar.gz #{backup_name}.sql"

    download "#{backup_path}.tar.gz", "tmp/#{backup_name}.sql.tar.gz"
  end

  task :apply, :roles => :db do
    if rails_env == 'production'
      logger.debug("ERROR: Not allowed to apply to production!")
    else
      run "cd #{current_path}/tmp && tar -zxf #{backup_name}.sql.tar.gz" do |ch, _, out|
        if out =~ /^replace /
          ch.send_data "y\n"
        else
          puts out
        end
      end

      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake db:drop db:create && mysql -u #{mysql_config['username']} -p#{mysql_config['password']} -D #{mysql_config['database']} < #{backup_path}"
    end
  end

  unless rails_env == 'production'
    before "database:apply", "services:stop"
    before "database:apply", "unicorn:stop"

    after "database:apply", "deploy:migrate"

    after "database:apply", "unicorn:start"
    after "database:apply", "services:start"
  end

  task :push, :roles => :db do
    if rails_env == 'production'
      logger.debug("ERROR: Not allowed to upload to production!")
    else
      upload "tmp/#{backup_name}.sql.tar.gz", "#{backup_path}.tar.gz"
    end
  end
end
