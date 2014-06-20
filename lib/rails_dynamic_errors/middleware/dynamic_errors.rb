require 'action_dispatch/middleware/exception_wrapper'

module RailsDynamicErrors
  class DynamicErrors
    def initialize(app)
      @app = app
    end

    def call(env)
      response = @app.call(env)
      # 404 errors for unmatched routes aren't actually raised until
      # ActionDispatch::DebugExceptions. If we're supposed to catch 404s and
      # the application indicates there was no matching route, throw and
      # handle a 404 generating exception
      if catch_not_found_error? && request_unhandled?(response)
        raise ActionController::RoutingError.new("No route matches [#{env['REQUEST_METHOD']}] #{env['PATH_INFO'].inspect}")
      else
        response
      end
    rescue Exception => exception
      process_exception(env, exception)
    end

    private
      def catch_not_found_error?
        can_handle_status_code?(404)
      end

      def can_handle_status_code?(status_code)
        http_error_codes_to_handle.include?(status_code)
      end

      def http_error_codes_to_handle
        Rails.application.config.rails_dynamic_errors.http_error_status_codes_to_handle || []
      end

      def request_unhandled?(response)
        # Returned by Rails when no matching route was found
        [404, {'X-Cascade' => 'pass'}, ['Not Found']] == response
      end

      def process_exception(env, exception)
        status_code = exception_status_code(env, exception)
        if can_handle_status_code?(status_code)
          generate_dynamic_error_page(env, exception, status_code)
        else
          raise exception
        end
      end

      def exception_status_code(env, exception)
        wrapper = ActionDispatch::ExceptionWrapper.new(env, exception)
        wrapper.status_code
      end

      def generate_dynamic_error_page(env, exception, status_code)
        env['PATH_INFO'] = dynamic_error_path(status_code)
        env['action_dispatch.exception'] = exception
        Rails.application.routes.call(env)
      end

      def dynamic_error_path(status_code)
        # Error page routes need to reflect where the engine has been mounted
        "#{RailsDynamicErrors::Engine.mounted_at}/#{status_code}"
      end
  end
end
