# config/unicorn.rb
# Set your full path to application.
app_dir = File.expand_path('../../', __FILE__)

# Set unicorn options
worker_processes 2
preload_app true
timeout 360

# Fill path to your app
working_directory app_dir

# Set up socket location
listen "#{app_dir}/tmp/sockets/unicorn.sock", :backlog => 64

# Loging
stderr_path "#{app_dir}/log/unicorn.stderr.log"
stdout_path "#{app_dir}/log/unicorn.stdout.log"

# Set master PID location
pid "#{app_dir}/tmp/pids/unicorn.pid"

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end

before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "#{app_dir}/Gemfile"
end


=begin
worker_processes 3
timeout 30
preload_app true
root = "/home/nyros/Apps/unicorn-delayone"
working_directory root

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end 

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
=end
=begin

worker_processes 4
#user "nyros", "unprivileged_group"
working_directory "/home/nyros/Apps/unicorn-delayone/current" # available in 0.94.0+
 
listen "/tmp/.sock", :backlog => 64
listen 8080, :tcp_nopush => true
 
timeout 30
 
# feel free to point this anywhere accessible on the filesystem
pid "/home/nyros/Apps/unicorn-delayone/shared/pids/unicorn.pid"
 
stderr_path "/home/nyros/Apps/unicorn-delayone/shared/log/unicorn.stderr.log"
stdout_path "/home/nyros/Apps/unicorn-delayone/shared/log/unicorn.stdout.log"
 
# combine REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
GC.copy_on_write_friendly = true
 
before_fork do |server, worker|
# the following is highly recomended for Rails + "preload_app true"
# as there's no need for the master process to hold a connection
#defined?(ActiveRecord::Base) and
# ActiveRecord::Base.connection.disconnect!
 
old_pid = "#{server.config[:pid]}.oldbin"
if old_pid != server.pid
begin
sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
Process.kill(sig, File.read(old_pid).to_i)
rescue Errno::ENOENT, Errno::ESRCH
end
end
end
 
after_fork do |server, worker|
# the following is *required* for Rails + "preload_app true",
#defined?(ActiveRecord::Base) and
# ActiveRecord::Base.establish_connection
end
=end