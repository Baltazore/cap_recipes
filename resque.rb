set_default(:resque_user) { user }
set_default(:resque_group) { user }

set_default(:workers) { {"*" => 1} }
set_default(:resque_kill_signal) { "QUIT" }

def workers_roles
  return workers.keys if workers.first[1].is_a? Hash
  [:resque_worker]
end

def for_each_workers(&block)
  if workers.first[1].is_a? Hash
    workers_roles.each do |role|
      yield(role.to_sym, workers[role.to_sym])
    end
  else
    yield(:resque_worker,workers)
  end
end

namespace :resque do
  desc "See current worker status"
  task :status, :roles => lambda { workers_roles() }, :on_no_matching_servers => :continue do
    command = "ls -l #{current_path}/tmp/pids/resque_worker_*.pid > /dev/null 2>&1; if [ \"$?\" = \"0\" ]; then \
      for f in $(ls #{current_path}/tmp/pids/resque_worker_*.pid); do ps -f -p $(cat $f) --ppid $(cat $f) | sed -n 2p ;done \
      ;fi"
    run(command)
  end

  desc "Start Resque workers"
  task :start, :roles => lambda { workers_roles() }, :on_no_matching_servers => :continue do
    NEED_START_COMMAND
  end

  # See https://github.com/defunkt/resque#signals for a descriptions of signals
  # QUIT - Wait for child to finish processing then exit (graceful)
  # TERM / INT - Immediately kill child then exit (stale or stuck)
  # USR1 - Immediately kill child but don't exit (stale or stuck)
  # USR2 - Don't start to process any new jobs (pause)
  # CONT - Start to process new jobs again after a USR2 (resume)
  desc "Quit running Resque workers"
  task :stop, :roles => lambda { workers_roles() }, :on_no_matching_servers => :continue do
    command = "ls -l #{current_path}/tmp/pids/resque_worker_*.pid > /dev/null 2>&1; if [ \"$?\" = \"0\" ]; then \
      for f in `ls #{current_path}/tmp/pids/resque_work*.pid`; do #{sudo} kill -s #{resque_kill_signal} `cat $f` ; rm $f ;done \
      ;fi"
    run(command)
  end

  desc "Restart running Resque workers"
  task :restart, :roles => lambda { workers_roles() }, :on_no_matching_servers => :continue do
    stop
    start
  end

  after "deploy:restart", "resque:restart"
end
