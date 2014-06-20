require 'rails/generators'

module RailsDynamicErrors
  # This is a generator that is used to install rails_dynamic_errors into a
  # Rails application. It runs all of the methods below.
  class InstallGenerator < Rails::Generators::Base
    # Add the gem configuration options to the Rails application's
    # config/application.rb file. These are all disabled by default so as to
    # cause minimum intrusion upon install.
    def configure_application
      application <<-APP
    # This option is used to set the HTTP error codes for which
    # rails_dynamic_errors will generate dynamic error pages. A good default
    # setup is [404, 422], which will catch the two main errors (excluding the
    # dreaded 500 Internal Server Error) for which Rails provides static HTML
    # error pages.
    # config.rails_dynamic_errors.http_error_status_codes_to_handle = [404, 422]
      APP
    end

    # Add mounting of the gem's engine to the the Rails application's
    # config/routes.rb file. The default mount path can be found in the
    # documentation for the RailsDynamicErrors module.
    def notify_about_routes
      insert_into_file File.join('config', 'routes.rb'), :before => /^end/ do
        %Q{
  # This line mounts RailDynamicErrors' routes on the '/errors' path of your
  # application. This means that any requests to URLs with this prefix in their
  # path will go to RailsDynamicErrors for processing.
  #
  # If you would like to change where this engine is mounted, simply change the
  # :at option to something different.
  mount RailsDynamicErrors::Engine, at: '#{RailsDynamicErrors::DEFAULT_MOUNT_POINT}'
        }
      end
    end
  end
end
