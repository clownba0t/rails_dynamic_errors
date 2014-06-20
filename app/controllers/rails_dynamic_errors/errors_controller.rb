module RailsDynamicErrors
  class ErrorsController < ApplicationController
    helper_method :status_code
    helper_method :status_name
    helper_method :error_message
  
    def show
      render template, layout: layout, status: status_code
    end
  
    private
      def layout
        template_exists?("errors", "layouts") ? "errors" : "application"
      end
  
      def template
        template_exists?(status_code, "errors") ? status_code : "show"
      end
  
      def status_code
        params[:code]
      end

      def status_name
        @status_name ||= Rack::Utils::HTTP_STATUS_CODES.fetch(status_code.to_i, "Error")
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
  end
end
