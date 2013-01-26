#before 'deploy:setup', 'rvm:install_rvm'
#set :rvm_install_type, :head # or:
#set :rvm_install_type, :stable
#before 'deploy:setup', 'rvm:install_ruby'
#set :rvm_install_ruby, :install # or:
#set :rvm_install_ruby, :reinstall
set :sudo, 'rvmsudo'
namespace :rvm do
  task :set_rvmrc do
    run "cd #{release_path} && echo 'rvm use #{rvm_ruby_string} --create' > .rvmrc"
  end
end
after 'deploy:update_code', 'rvm:set_rvmrc'
