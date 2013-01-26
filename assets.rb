namespace :deploy do
  namespace :assets do
    # We analyze if changes were made to not precompile assets otherwise.
    task :precompile, :roles => :web, :except => { :no_release => true } do
      `git fetch`
      command = "#{source.local.log(previous_revision, "origin/#{branch}")} vendor/assets/ app/assets/ lib/assets/ config/ | wc -l"
      logger.info command
      if `#{command}`.to_i > 0
        logger.info "Running asset pre-compilation"
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end
end
