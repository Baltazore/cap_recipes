set_default(:mysql_copy_shared_folders) { 'system' }

namespace :mysql_copy do
  desc <<-DESC
  MySQL should be used for both environments!
  Loads db and assets to development.
  To run: cap RAILS_ENV download_data_to_development
  e.g. cap staging download_data_to_development
  DESC
  task :download_data_to_development, :roles => :app do
    download_db_to_development
    download_assets_to_development
  end

  desc <<-DESC
  Loads assets
  To run: cap RAILS_ENV download_assets_to_development
  e.g. cap staging download_assets_to_development
  DESC
  task :download_assets_to_development, :roles => :app do
    # Copy media files under system
    media_tar = "/tmp/#{application}_#{stage}_media.tar"
    run "cd #{shared_path} && tar cf #{media_tar} #{Array(mysql_copy_shared_folders).join(' ')} --exclude=original"
    get media_tar, media_tar
    `cd public && tar xf #{media_tar};rm -f #{media_tar}`
  end

  desc <<-DESC
  MySQL should be used for both environments!
  Loads the RAILS_ENV database into your development environment
  To run: cap RAILS_ENV download_db_to_development
  e.g. cap staging download_db_to_development
  DESC
  task :download_db_to_development, :roles => :app do
    require 'yaml'

    config = YAML::load_file('config/database.yml')['development']
    p_config = load_remote_yml(rails_env, "#{current_path}/config/database.yml")

    # copy the SQL data
    filename = "/tmp/dump.#{Time.now.strftime '%Y-%m-%d_%H:%M:%S'}.sql.gz"
    run "mysqldump -u #{p_config['username']} --password='#{p_config['password']}' #{p_config['database']} | gzip > #{filename}"
    # copy down to your tmp directory
    get filename, filename
    # load into the development database
    `gunzip -c #{filename} | mysql -u #{config['username']} --password='#{config['password']}' #{config['database']} && rm -f gunzip #{filename}`
  end



  def load_remote_yml(environment, path)
    yml = "config/database.#{environment}-#{Time.now.strftime '%Y-%m-%d_%H:%M:%S'}.yml"
    begin
      get path, yml
      config = YAML::load_file(yml)
      return config[environment.to_s]
    rescue
      raise
    ensure
      `rm -f #{yml}`
    end
  end
end
