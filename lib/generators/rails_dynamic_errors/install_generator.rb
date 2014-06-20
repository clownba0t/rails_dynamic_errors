require 'rails/generators'

module RailsDynamicErrors
  class InstallGenerator < Rails::Generators::Base

    # Allow gem users to decorate (class_eval or completely redefine)
    # ErrorsController to suit their purposes
    def configure_application
      application <<-APP

    # Load the ErrorsController decorator class (if there is one)
    config.to_prepare do
      Dir.glob(File.join(File.dirname(__FILE__), "../app/controllers/errors_controller_decorator.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    # This option is used to set the HTTP error codes for which
    # rails_dynamic_errors will generate dynamic error pages. A good default
    # setup is [404, 422], which will catch the two main errors (excluding the
    # dreaded 500 Internal Server Error) for which Rails provides static HTML
    # error pages.
    # config.rails_dynamic_errors.http_error_status_codes_to_handle = [404, 422]
      APP
    end

    # Mount the gem's engine in the application at the default '/errors' path
    def notify_about_routes
      insert_into_file File.join('config', 'routes.rb'), :before => /^end/ do
        %Q{
  # This line mounts RailDynamicErrors' routes on the '/errors' path of your
  # application. This means that any requests to URLs with this prefix in their
  # path will go to RailsDynamicErrors for processing.
  #
  # If you would like to change where this engine is mounted, simply change the
  # :at option to something different.
  mount RailsDynamicErrors::Engine, at: 'errors'
        }
      end
    end
  end
end
