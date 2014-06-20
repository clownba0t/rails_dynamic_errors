module RailsDynamicErrors
  class Engine < ::Rails::Engine
    isolate_namespace RailsDynamicErrors

    # Add configuration options within namespace in the main application
    config.rails_dynamic_errors = ActiveSupport::OrderedOptions.new

    initializer "rails_dynamic_errors.install_middleware" do |app|
      # Avoid inserting if already inserted?
      app.middleware.use RailsDynamicErrors::DynamicErrors
    end

    # Returns path at which the engine is mounted 
    def self.mounted_at
      route = Rails.application.routes.routes.detect do |route|
        route.app == self
      end
      route && route.path.spec.to_s
    end
  end
end
