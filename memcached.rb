set_default(:memcached_pid) { "/var/run/memcached/memcached.pid"}

namespace :memcached do
  %w[start stop restart].each do |command|
    desc "#{command} memcached"
    task command, roles: :web do
      run "#{sudo} /etc/init.d/memcached #{command}"
    end
  end
end
