set_default(:files_backup_folder_name) { 'files_backups' }
set_default(:files_backup_folder_for_backup) { "#{current_path}/public" }
set_default(:files_backup_items_to_include) { %w[ ckeditor_assets system favicon.ico ] }
set_default(:files_backup_cron_title) { "periodic files backup for #{application}" }
set_default(:files_backup_script_name) { 'backup_files.sh' }

namespace :files_backup do
  desc 'Initialize periodic backup with cron'
  task :setup, roles: :web do
    upload_script_file
    update_crontab
  end

  desc 'Update script file'
  task :upload_script_file, roles: :web do
    run "mkdir -p /home/#{user}/scripts"
    template 'files_backup.sh', "/home/#{user}/scripts/#{files_backup_script_name}"
    run "chmod +x /home/#{user}/scripts/#{files_backup_script_name}"
    puts 'Script file created'
  end

  desc 'Update crontab for files backup'
  task :update_crontab, roles: :web do
    cron_task = "0 3 * * * /home/#{user}/scripts/#{files_backup_script_name}"
    update_crontab_helper(files_backup_cron_title, cron_task)
  end
end
