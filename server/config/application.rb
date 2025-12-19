require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_cable/engine'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cartify
  class Application < Rails::Application
    config.load_defaults 7.1
    config.api_only = true

    # TimeZone
    config.time_zone = 'UTC'

    # Auto-load paths
    config.autoload_paths << Rails.root.join('app', 'services')
    config.autoload_paths << Rails.root.join('app', 'policies')
    config.autoload_paths << Rails.root.join('app', 'graphql')

    # ActiveJob adapter
    config.active_job.queue_adapter = :sidekiq

    # Generators
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end
  end
end
