require 'engine_helper'

module RailsDynamicErrors
  # This is the engine that provides dynamic error page generation for
  # rails_dynamic_errors. It is designed to be mounted at an appropriate route
  # within the main application, permitting the handling of generic error URLs
  # that map to this base route.
  #
  # It also adds a namespace for rails_dynamic_errors configuration options
  # within the parent application. These are accessible as per standard Rails
  # application configuration options via:
  #
  # Rails.application.config.rails_dynamic_errors
  #
  # End users should never use this engine directly. It is created automatically
  # when the main application is run. An install generator is included which
  # updates the config/routes.rb file of the main application to include the
  # necessary code to mount the engine at a default route.
  #
  # Note: the engine is namespaced to 'RailsDynamicErrors'.
  class Engine < ::Rails::Engine
    isolate_namespace RailsDynamicErrors
    extend EngineHelper::ClassMethods

    # Add configuration options within namespace in the main application
    config.rails_dynamic_errors = ActiveSupport::OrderedOptions.new

    initializer "rails_dynamic_errors.install_middleware" do |app|
      # Avoid inserting if already inserted?
      app.middleware.use RailsDynamicErrors::DynamicErrors
    end
  end
end
