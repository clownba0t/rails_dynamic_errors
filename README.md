rails_dynamic_errors
====================

## Installation:

1. Add to your Gemfile:

        gem 'rails_dynamic_errors', :git => 'git://github.com/clownba0t/rails_dynamic_errors.git', :branch => "release-0.0.1"

2. Run the install generator:

	rails g rails_dynamic_errors:install


## Configuration:

Out of the box, rails_dynamic_errors doesn't actually handle any errors from your application. To enable the generation of dynamic error pages, you must provide it with a list of HTTP status codes it should handle. This should be done as part of your application configuration in config/application.rb.

The install generator adds a section for configuration of rails_dynamic_errors with examples of the major options, all disabled. If you'd like to use the default (recommended) setup, simply uncomment the following line:

    # config.rails_dynamic_errors.http_error_codes_to_handle = [404, 422]

To generate dynamic errors for any HTTP status code, simply add it to the array.

rails_dynamic_errors works by setting up a glob route within your application's routes. The functionality of the gem is provided to your application by mounting the gem's engine at the base path of this route, which defaults to '/errors'. This mount is set up as part of the install generator, which adds the following line to your config/routes.rb file:

  mount RailsDynamicErrors::Engine, at: 'errors'

If '/errors' is not a convenient base path, you are free to change it to whatever you like.


## Usage:

Once installed and configured, rails_dynamic_errors will automatically capture all application errors that result in HTTP status codes in the list of codes to handle (as configured above) and generate dynamic error pages.

The error pages are built using the layouts in your application (i.e. in app/views/layouts). If an 'errors' layout exists in here it will be used, otherwise the default 'application' layout will be used.

The gem itself contains a default template for rendering an error, but it is extremely simple. You will almost definitely want to override it with a template of your own. You can do this by creating the following directory:

app/views/rails_dynamic_errors/errors/

Within this directory you can create a 'show' template, and it take precedence over the gem's basic one.

Additionally, custom templates can be created for each HTTP status code and they will be used in favour of the default 'show'. Simply name them using the HTTP status code they pertain to (e.g. '404.html.erb') and place them in the directory above.

Various view helpers are available for use within your error templates:
	status_code # (
	status_name # (
	error_message # (contains an error
	exception # (

The dynamic page generation is handled by the ErrorsController controller within the gem. You are more than welcome to modify the functionality provided by this controller, using one of the following methods:

1. Completely redefine the class using the following template:

	# app/controllers/rails_dynamic_errors/errors_controller.rb
	class RailsDynamicErrors::ErrorsController < ApplicationController
          .
          .
          .
        end

2. 'Decorate' the class using a supported mechanism:

	# app/controllers/errors_controller_decorator.rb
	RailsDynamicErrors::ErrorsController.class_eval do
	end

3. 'Decorate' the class using a standard config/initializer monkey patch.


## Notes:

rails_dynamic_errors works by loading a Rack middleware (called RailsDynamicErrors::DynamicErrors) into your application's middleware stack. By default, this is added to the bottom of the stack. Depending on your application's setup (configuration, other gems, gem load order, etc.), however, this location may change in the final list of middlewares. Please be aware that due to the way this gem works, the 'after' functionality of any middlewares located below RailsDynamicErrors::DynamicErrors will not work. If this is a problem, you will need to reorder the middlewares to ensure that RailsDynamicErrors::DynamicErrors is located at the very bottom of the stack. (TODO: This can probably be done using an initializer?)

## Background:

Rails comes with decent middleware to handle and display exceptions and
error conditions returned from the application - namely, ActionDispatch's
ShowExceptions and DebugExceptions. However, depending on your exception
handling ideology, these classes may not suffice.

By default, these classes do not support generation of dynamic error pages.
It is understandable that 500 errors result in the return of a static
HTML page, but there's no real reason a 404 shouldn't be handled
dynamically.

Rails, as always, does provide a nice way to introduce this functionality
without changing any base code. In this case, it's the 'exceptions_app'
application configuration parameter, which identifies a Rack compatible
application to use to handle the display of exceptions. If set to
'self.routes' or a custom handler (ActionDispatch::PublicExceptions sub
class), it's not difficult to set up custom error handling via a controller.

Unfortunately, due to these exception handling middlewares being in the
middle of the middleware stack, a lot of functionality provided by other
middlewares between the application and these middlewares is not made
available for dynamic error processing. Amongst other things, this includes
the session, flash and cookies.

This middleware is designed to work around this issue. It should be
inserted into the middleware stack below any middlewares which provide
functionality that is required in dynamic error processing. Ideally it
should sit right above the actual application.

It works by capturing all exceptions returned from the application (as well
as the case in which a 404 response is returned due to no matching route
being available for the request) and selectively handling those it is
configured to generate dynamic error pages for.

## Installation:

1) Ensure that your application configuration is set to autoload from lib.

2) Add the following to your config/application.rb file:

   config.middleware.use(Middleware::DynamicErrors, [ <codes to handle> ])

   See below for explanation of <codes to handle>.

## Usage:

To generate a dynamic error page for a given exception, the following steps
must be taken:

1) Identify the HTTP status code associated with the exception - see
   ActionDispatch::ExceptionWrapper for how this is done.
2) Add the status code to the array argument provided to the middleware
   insertion in config/application.rb (see <codes to handle> above).
3) Add a route to your application that maps the status code to the
   appropriate controller which will generate the dynamic page. The
   following format is recommended:

   match '/<status code>', :to => "<route>#<action>", via: :all

If the status code of an exception is not in the list to handle, the
exception is simply re-raised for default processing by ShowExceptions.
This will mean that any middlewares between this middleware and
ShowExceptions will not be run.

Should an exception be raised by your error page generation code, it will
not be caught. This means it will be handled as per default by
ShowExceptions. While it is not recommended, this means you can safely (?)
attempt to generate dynamic error pages for 500 errors if you really want
