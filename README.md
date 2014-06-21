rails_dynamic_errors
====================

## Motivation

Rails provides robust exception handling out of the box via middleware and a set of static HTML pages in the `/public` directory of your application. However, this strategy is not always ideal, especially for production applications. The static HTML pages naturally do not reflect the layout of your application, and customizing them adds extra maintenance whenever that layout does change.

Particularly for 'safe' errors such as 404s, there's no real reason why dynamic error pages can't be generated. This gem is designed to provide this functionality. Its key features are:

**Selective processing**

Configure the HTTP error status codes (404, 422, etc.) you wish to process dynamically. All other status codes will be passed through to Rails for default handling.

**Respect's Rails' error handling strategy**

Rails can be configured to show or raise exceptions in each environment. Additionally, it can be configured to return detailed exception information. This gem respects those configuration options, simply passing the responsibility for handling the error to Rails unless it is configured to show exceptions and not show detailed exceptions.

**Preserves Rails middleware functionality**

Many existing dynamic error generation approaches leave these non-functional, which results in the flash, cookies and sessions (amongst other things) not functioning.

## Installation

From within your Rails application's base directory:

1. Edit your Gemfile and add:

	`gem 'rails_dynamic_errors'`

2. Install the gem:

	`bundle`

3. Run the included install generator:

	`rails g rails_dynamic_errors:install`


## Configuration

#### Rails Environment

Rails' built in exception handling, which is what serves the static HTML error pages or produces detailed exception information, is controlled by two configuration options. These are:

```
config.action_dispatch.show_exceptions     # Whether or not to show exceptions or raise them to the webserver (usually results in an empty page)
config.consider_all_requests_local         # 'local' requests result in detailed exception information rather than the default static error page
```

Please note that these options are set at the environment level (i.e. development, test, production) in the appropriate files within the `/config/environments` directory of your application.

In order to generate dynamic error pages in each environment, the options must be set as follows:

```
config.action_dispatch.show_exceptions = true
config.consider_all_requests_local     = false
```

See the Notes section below for more information and a few gotchas.


#### HTTP Error Status Codes to Handle

Dynamic error page generation is handled selectively based on the HTTP error status code exceptions and error conditions map to. For example, ActiveRecord::RecordNotFound exceptions map to a status code of 404. So as to cause minimum intrustion, the installer does not enable the generation of any dynamic error pages. It does, however, add a configuration option that lets you specify which HTTP error statuc codes to handle to the top of the `/config/application.rb` file within your application, as follows:

`    # config.rails_dynamic_errors.http_error_codes_to_handle = [404, 422]`

Note that by default this option is disabled. If you would like to enable dynamic error page generation for the default (recommended) set of HTTP error status codes, simply uncomment it. To capture any set of HTTP error status codes, simply set the option to an array of integers representing those codes (see example above).

Refer to ActionDispatch::ExceptionWrapper for details on which exceptions map to which HTTP error status codes.

#### Routing

The gem mounts an engine into your application that performs the dynamic error page generation. The installer adds the necessary configuration to the bottom of the `/config/routes.rb` file within your application. By default the engine is mounted at `/errors`, but you are more than welcome to change this if you wish.

## Usage

Once installed and configured, all application errors that result in HTTP status codes in the list of codes to handle (as configured above) will be captured and generate dynamic error pages for them. See below for more information on each step of this process (and how to customise it).

#### Routes

As mentioned above, the gem features an engine which is automatically mounted within your application. The engine handles routes in the following format:

`/errors/*`

Note that this is a glob route. Although it is primarily designed for HTTP errors (e.g. `/errors/404`), you can actually use it as a generic error handler simply by routing to `/errors/<error code>/`. For example, you could generate a dynamic error page for an error of code `invalid_ninja` with the route `/errors/invalid_ninja`, which is quite handy.

#### Controller

The dynamic page generation is handled by a controller within the gem. You are more than welcome to modify or completely override the functionality provided by this controller within your application, as follows:

* Redefinition (override):

```
# app/controllers/rails_dynamic_errors/errors_controller.rb

class RailsDynamicErrors::ErrorsController < RailsDynamicErrors::ApplicationController
  .
  .
  .
end
```

* 'Decoration':

```
# app/controllers/rails_dynamic_errors/errors_controller.rb

RailsDynamicErrors::ErrorsController.class_eval do
  .
  .
  .
end
```

* Monkey patch via an initializer:

```
# config/initializers/rails_dynamic_errors_errors_controller.rb

RailsDynamicErrors::ErrorsController.class_eval do
  .
  .
  .
end
```

#### Views

###### Layouts

The gem does not contain any layouts. Rather, the error pages are built using the layouts in your application (i.e. in `/app/views/layouts`). If an `errors` layout exists in here it will be used, otherwise the default `application` layout will be used.

###### Templates

The gem does contain an extremely simple default template for rendering errors using the `#show` action of the controller. You will almost definitely want to override it with a template of your own. You can do this by creating the following directory within your application:

`app/views/rails_dynamic_errors/errors/`

Simply create a `show` template in the format of your choice and it will take precedence over the gem's basic one.

Additionally, custom templates can be created for each error code you expect to receive (`404`, `invalid_ninja`, etc.), and they will be used in favour of the default `show` template. Simply name them using the HTTP status code they pertain to (e.g. `404.html.erb`) and place them in the directory above.

###### View Helpers

Several helper methods are available for use within your templates:

`error_code`

Returns the error code provided in the path

`error_name`

Returns a short error name associated with the error. If the error code is a HTTP status code this will be the appropriate error name ("Not Found" for 404, etc.), otherwise "Internal Server Error" is returned.

`error_message`

Returns the message in the exception that caused the error (if there is one), otherwise a default message.

## Notes

#### 500 Errors

500 errors have typically been a thorn in the side of dynamic error generation. After all, if your dynamic error generation code or code that it relies on is broken, then your application is liable to die. Whether you want to tackle this beast or not is entirely up to you. In theory it should be safe, as any exceptions raised within the dynamic error page generation should simply bubble up the middleware stack until they hit ActionDispatch::ShowExceptions, where the default static 500.html page will be rendered.

#### Middleware Ordering

The gem inserts the middleware it uses into your application's middleware stack at the bottom. Depending on your application's setup (configuration, other gems, gem load order, etc.), however, this location may change in the final list of middlewares. Please be aware that due to the way the middleware works, the 'after' functionality of any middlewares located between the application and this gem's middleware will not work. If this is a problem, you will need to reorder the middlewares to ensure that RailsDynamicErrors::DynamicErrors is located at the very bottom of the stack.

#### Rails' Exception Handling Configuration

Please remember that each of the Rails environments (development, test and production) have their own exception handling configuration options. If you are encountering a situation where dynamic error pages are/aren't being generated when they shouldn't/should be, please check the values of these options first. This is particularly so for the test environment, which tends to be less 'explored' than the other environments.

If you want to test what is produced by an exception with different combinations of the values for the two options mentioned above and don't want to or can't change the values in the environment file, consider using the following code (Rspec only, sorry):

Add the following helper function to either your spec file, spec helper or support file:

```
  def set_environment_variable(variable, value)
    original_value = Rails.application.env_config[variable]
    Rails.application.env_config[variable] = value
    original_value
  end
```

Before the tests you want to run with <variable name> set to <value> (e.g. 'action_dispatch.show_detailed_exceptions' to false):

```
  context "tests with <variable name> set to <value>" do
    around(:each)
      original = set_environment_variable('<variable name>', false)
      example.run
      set_environment_variable('action_dispatch.show_exceptions', original)
    end
  end
```

#### Help
This is my first gem, so there are no doubt many things that can be done to improve it. All constructive feedback, no matter how general or detailed, would be absolutely lovely. Or, you can fork, improve, pull-request ;)

## TO DO
* Prevent insertion of middleware if it's already inserted? Or perhaps shift it to the bottom instead?
* I18n support (especially for error names and messages)
* Tests for:
  * functionality if the mount point is changed
  * exception during processing -> Rails 500 page
  * ability to use sessions, flash and cookies
  * routes
  * impact on application after install but before generator install
  * different versions of Rails
  * tests for configuration option values
* DRY up specs
* Install generator/rake task to copy default 'show' template into application for modification
* Provide warnings in the log when invalid config options are received
* HTTP status code checker (avoid status codes like 9999 in the options)
* Update YARD doco
