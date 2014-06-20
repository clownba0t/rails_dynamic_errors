module RailsDynamicErrors
  module ApplicationHelper
    def method_missing(method, *args, &block)
      if method.to_s.end_with?('_path', '_url') && main_app.respond_to?(method)
        main_app.send(method, *args)
      else
        super
      end
    end

    def respond_to?(method, include_all = false)
      if method.to_s.end_with?('_path', '_url') && main_app.respond_to?(method)
        true
      else
        super
      end
    end
  end
end
