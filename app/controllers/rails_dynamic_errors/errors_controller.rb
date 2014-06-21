require 'action_dispatch/middleware/exception_wrapper'

module RailsDynamicErrors
  class ErrorsController < ::ApplicationController
    helper_method :error_code
    helper_method :error_name
    helper_method :error_message
  
    def show
      render template, layout: layout, status: status_code
    end
  
    private
      def error_code
        # The route that leads to this controller is set up with a glob that
        # maps to params[:code]. Unfortunately, because Rails memoizes request
        # parameters, this mapped data is not available if we arrive in this
        # controller after processing a request to a valid route but with a
        # non-existent resource. Thankfully we can just take the same steps
        # here as the glob anyway - extract the code from the path.
        @error_code ||= env['PATH_INFO'][1..-1]
      end

      def error_name
        @error_name ||= Rack::Utils::HTTP_STATUS_CODES.fetch(status_code.to_i, 'Internal Server Error')
      end
  
      def error_message
        if exception && exception.message && exception.class.name != exception.message
          @message ||= exception.message
        else
          @message ||= "An error has occurred. This site administrator has been notified of this issue. We apologise for any inconvenience."
        end
      end
  
      def exception
        @exception ||= env['action_dispatch.exception']
      end

      def status_code
        @status_code ||= (exception) ? ActionDispatch::ExceptionWrapper.new(env, exception).status_code.to_s : '500'
      end

      def layout
        template_exists?('errors', 'layouts') ? 'errors' : 'application'
      end
  
      def template
        template_exists?(error_code, 'rails_dynamic_errors/errors') ? error_code : 'show'
      end
  end
end
