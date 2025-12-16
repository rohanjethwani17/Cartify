# Puma configuration file

# Thread pool
max_threads_count = ENV.fetch('RAILS_MAX_THREADS') { 5 }
min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
threads min_threads_count, max_threads_count

# Workers (processes)
workers ENV.fetch('WEB_CONCURRENCY') { 2 }

# Use preload for better memory usage with workers
preload_app!

# Specifies the port that Puma will listen on
port ENV.fetch('PORT') { 3000 }

# Environment
environment ENV.fetch('RAILS_ENV') { 'development' }

# PID file
pidfile ENV.fetch('PIDFILE') { 'tmp/pids/server.pid' }

# Allow workers to reload after this many requests
worker_timeout 3600 if ENV.fetch('RAILS_ENV', 'development') == 'development'

# Reconnect to database and Redis when forking
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

plugin :tmp_restart
