set_default(:database_backup_folder_name) { 'periodic_backups' }
set_default(:database_backup_cron_title) { "periodic backup for #{application}" }
set_default(:database_backup_script_name) { 'create_mysql_backup.sh' }

# Set to false to keep all backups
set_default(:database_backup_keep_backups_count) { 14 }

namespace :database_backup do
  desc 'Initialize periodic backup with cron'
  task :setup, roles: :db do
    upload_script_file
    update_crontab
  end

  desc 'Update script file'
  task :upload_script_file, roles: :db do
    run "mkdir -p /home/#{user}/scripts"
    template 'mysql_backup.sh', "/home/#{user}/scripts/#{database_backup_script_name}"
    run "chmod +x /home/#{user}/scripts/#{database_backup_script_name}"
    puts 'Script file created'
  end

  desc 'Update crontab for database backup'
  task :update_crontab, roles: :db do
    cron_task = "0 3 * * * /home/#{user}/scripts/#{database_backup_script_name}"
    update_crontab_helper(database_backup_cron_title, cron_task)
  end
end
