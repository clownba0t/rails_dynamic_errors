require 'action_dispatch/middleware/exception_wrapper'

module RailsDynamicErrors
  class DynamicErrors
    def initialize(app, codes_to_handle = [])
      @app = app
      @codes_to_handle = codes_to_handle
    end

    def call(env)
      response = @app.call(env)
      if request_unhandled?(response)
        raise ActionController::RoutingError.new("No route matches [#{env['REQUEST_METHOD']}] #{env['PATH_INFO'].inspect}")
      else
        response
      end
    rescue Exception => exception
      process_exception(env, exception)
    end

    private
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

      def can_handle_status_code?(status_code)
        @codes_to_handle.include?(status_code)
      end

      def generate_dynamic_error_page(env, exception, status_code)
        env["PATH_INFO"] = "/errors/#{status_code}"
        env["action_dispatch.exception"] = exception
        Rails.application.routes.call(env)
      end
  end
end
