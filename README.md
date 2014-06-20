rails_dynamic_errors
====================

## Installation:

From within your Rails application's base directory:

1. Edit your Gemfile and add:

        gem 'rails_dynamic_errors', :git => 'git://github.com/clownba0t/rails_dynamic_errors.git', :branch => "release-0.0.3"

2. Install the gem:

	bundle

3. Run the included install generator:

	rails g rails_dynamic_errors:install


## Configuration:

#### HTTP Error Codes to Handle
Out of the box, rails_dynamic_errors doesn't actually handle any errors from your application. To enable its generation of dynamic error pages, you must first configure it with a list of HTTP status codes that should be handled. This should be done within your application configuration in config/application.rb.

The install generator adds a section for configuration of rails_dynamic_errors with examples of the major options, all disabled. If you'd like to use the default (recommended) setup, simply uncomment the following line:

    # config.rails_dynamic_errors.http_error_codes_to_handle = [404, 422]

To generate dynamic errors for any HTTP status code, simply add it to the array.

#### Routing

rails_dynamic_errors uses a Rack middleware behind the scenes to capture errors. The error processing and page generation is then handled by a controller, which is routed to from the middleware. This means that rails_dynamic_errors has to install some routes in your application. This is also carried out by the install generator, which adds a line to your application's config/routes.rb to mount the gem's engine. By default this is mounted at '/errors', but you are welcome to change it,

## Usage:

Once installed and configured, rails_dynamic_errors will automatically capture all application errors that result in HTTP status codes in the list of codes to handle (as configured above) and generate dynamic error pages for them. See below for more information on each step of this process (and how to customise it).

#### Routes

As mentioned above, the gem features an engine which is automatically mounted within your application. The engine handles routes in the following format:

`/errors/*`

Note that this is a glob route. Although it is primarily designed for HTTP errors (e.g. /errors/404), you can actually use it as a generic error handler simply by using an appropriate route. For example, you could geneate a dynamic error page for an error named 'invalid_ninja' with the route '/errors/invalid_ninja'. Handy!

#### Controller

The dynamic page generation is handled by a controller within the gem. You are more than welcome to modify the functionality provided by this controller, using one of the following methods:

1. Completely redefine the class using the following template:

```
# app/controllers/rails_dynamic_errors/errors_controller.rb
class RailsDynamicErrors::ErrorsController < ApplicationController
  .
  .
  .
end
```

2. The install generator configures your application to automatically load a decorator class for the controller from app/controllers/errors_controller_decorator.rb. This allows you to nicely modify the class without redefining it, i.e.:

```
# app/controllers/errors_controller_decorator.rb
RailsDynamicErrors::ErrorsController.class_eval do
end
```

3. You can always use a standard config/initializer monkey patch :)


#### Views

###### Layouts

The gem does not contain any layouts. Rather, the error pages are built using the layouts in your application (i.e. in app/views/layouts). If an 'errors' layout exists in here it will be used, otherwise the default 'application' layout will be used.

###### Templates

The gem does contain an extremely simply default template for rendering errors using the 'show' action of the controller. You will almost definitely want to override it with a template of your own. You can do this by creating the following directory within your application:

app/views/rails_dynamic_errors/errors/

Simply create a 'show' template in the format of your choice and it will take precedence over the gem's basic one.

Additionally, custom templates can be created for each error code you expect to receive ('404', 'invalid_ninja', etc.), and they will be used in favour of the default 'show' template. Simply name them using the HTTP status code they pertain to (e.g. '404.html.erb') and place them in the directory above.

###### View Helpers

Several helper methods are available for use within your error templates:

*`error_code`*
Returns the error code provided in the path

*`error_name`*
Returns a short error name associated with the error. If the error code is a HTTP status code this will be the appropriate error name ("Not Found" for 404, etc.), otherwise "Internal Server Error" is returned.

*`error_message`
Returns the message in the exception that caused the error (if there is one), otherwise a default message.

## Notes:

#### 500 Errors

500 errors have typically been a thorn in the side of dynamic error generation. After all, if your dynamic error generation code or code that it relies on is broken, then your application is liable to die. Whether you want to tackle this beast or not is entirely up to you. In theory it should be safe, as any exceptions raised within the dynamic error page generation should simply bubble up the middleware stack until they hit ActionDispatch::ShowExceptions where the default static 500.html page will be rendered.

#### Middleware Ordering

The gem inserts the middleware it uses into your application's middleware stack at the bottom. Depending on your application's setup (configuration, other gems, gem load order, etc.), however, this location may change in the final list of middlewares. Please be aware that due to the way the middleware works, the 'after' functionality of any middlewares located between the application and this gem's middleware will not work. If this is a problem, you will need to reorder the middlewares to ensure that RailsDynamicErrors::DynamicErrors is located at the very bottom of the stack.

## TO DO
* Testing to ensure 500 errors don't blow up the application
* Prevent insertion of middleware if it's already inserted? Or perhaps shift it to the bottom instead?
