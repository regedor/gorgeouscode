require File.expand_path("../boot", __FILE__)

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Gc
  class Application < Rails::Application
    config.sass.preferred_syntax = :sass

    config.autoload_paths << Rails.root.join("lib", "modules")

    # load engine's routes after main app's
    initializer :munge_routing_paths, after: :add_routing_paths do |app|
      engine_routes_path = app.routes_reloader.paths.select { |path| path =~ // }.first
      app.routes_reloader.paths.delete(engine_routes_path)
      app.routes_reloader.paths << engine_routes_path
    end

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
