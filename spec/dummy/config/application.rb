require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)
require "rails_dynamic_errors"

module Dummy
  class Application < Rails::Application
    
    config.to_prepare do
      # Load the ErrorsController decorator class (if there is one)
      Dir.glob(File.join(File.dirname(__FILE__), "../app/controllers/errors_controller_decorator.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    # This option is used to set the HTTP error codes for which
    # rails_dynamic_errors will generate dynamic error pages. A good default
    # setup is [404, 422], which will catch the two main errors (excluding the
    # dreaded 500 Internal Server Error) for which Rails provides static HTML
    # error pages.
    # config.rails_dynamic_errors.http_error_codes_to_handle = [404, 422]
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end

