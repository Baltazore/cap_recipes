def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

def template(from, to, server_options = {})
  from_file = File.expand_path("../templates/#{from}.erb", __FILE__)
  erb = File.read(from_file)
  put ERB.new(erb).result(binding), to, server_options
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

def update_crontab_helper(title, command)
    # Save old crontab
    old_crontab = capture "#{sudo} crontab -u #{user} -l 2> /dev/null"
    puts 'Old crontab:'
    puts old_crontab.inspect
    # Remove old crontask
    old_crontab.gsub!(/#---#{title}\s*?\n.+?\n#---\s*?\n/, '')
    old_crontab.strip!
    new_crontab = [old_crontab, "#---#{title}", command, '#---'].join(" \n") << " \n"
    new_crontab.gsub!(/(\r*\n)+/, "\n")
    puts 'Updated crontab:'
    puts new_crontab.inspect
    # Update crontab through tmp file
    tmp_filename = "/tmp/tmp_cronbtab_#{Time.new.strftime("%Y%m%d%H%M%S%N")}"
    put new_crontab, tmp_filename
    run "cat #{tmp_filename} | #{sudo} crontab -u #{user} -"
    run "rm #{tmp_filename}"
    puts 'Crontab updated'
end
