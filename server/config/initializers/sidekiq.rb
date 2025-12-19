# Sidekiq configuration

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') { 'redis://localhost:6379/0' } }

  # Enable ActionCable connections from Sidekiq workers
  config.on(:startup) do
    ActiveRecord::Base.establish_connection
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') { 'redis://localhost:6379/0' } }
end
