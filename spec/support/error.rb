# From ActionDispatch::ExceptionWrapper
HTTP_STATUS_CODE_RAILS_EXCEPTIONS = {
  400 => ActionController::BadRequest              ,
#  400 => ActionDispatch::ParamsParser::ParseError  ,
#  400 => ActionController::ParameterMissing        ,
  404 => ActionController::RoutingError            ,
#  404 => AbstractController::ActionNotFound        ,
  405 => ActionController::MethodNotAllowed        ,
#  405 => ActionController::UnknownHttpMethod       ,
  406 => ActionController::UnknownFormat           ,
  422 => ActionController::InvalidAuthenticityToken,
  501 => ActionController::NotImplemented          ,
} 

def build_environment_after_exception_for_status_code(status_code, message = nil)
  @exception = HTTP_STATUS_CODE_RAILS_EXCEPTIONS.fetch(status_code, Exception).new(message)
  controller.env["PATH_INFO"] = "#{status_code}"
  controller.env["action_dispatch.exception"] = @exception
end
