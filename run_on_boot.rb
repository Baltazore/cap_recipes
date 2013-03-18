# Not tested and not finished
#namespace :run_on_boot do
#  desc 'Upload config on server from template'
#  task :upload do
#    old_rc = capture("#{sudo} cat /etc/rc.local").gsub!(/(\r*\n)+/, "\n")
#    new_line = "sudo -u USER bash -l -c 'cd /home/USER/www/SITE/current &&  bundle exec  thin start -C /etc/thin/SITE_production_thin.conf --socket tmp/thin.sock'"
#    title = "#-------Boot script for #{application}"
#    old_rc.gsub!(/#{title}\s*?\n.+?\n#---\s*?\n/, '')
#    TODO: need to implement
#    new_rc = old_rc.insert_before('exit 0', [title, new_line, '#---'].join("\n"))
#    # Update through tmp file
#    tmp_filename = "/tmp/tmp_rc_local_#{Time.new.strftime("%Y%m%d%H%M%S%N")}"
#    put new_rc, tmp_filename
#    run "sudo cat #{tmp_filename} > /etc/rc.local"
#    run "rm #{tmp_filename}"
#  end
#end
