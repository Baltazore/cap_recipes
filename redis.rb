set_default(:redis_pid) { "/var/run/redis.pid" }

namespace :redis do
  %w[start stop restart].each do |command|
    desc "#{command} redis"
    task command, roles: :redis do
      run "#{sudo} /etc/init.d/redis-server #{command}"
    end
  end
end