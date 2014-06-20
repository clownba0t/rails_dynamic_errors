require 'spec_helper'

describe RailsDynamicErrors::ErrorsController do
  describe "GET show" do
    before(:each) do
      @error_code = 404
    end

    it "makes the status code available" do
      build_environment_after_exception_for_status_code(@error_code)
      get :show, code: @error_code, use_route: :rails_dynamic_errors
      controller.send(:status_code).should eq(@error_code.to_s)
    end

    context "makes a friendly error name available" do
      context "when the status code is a valid HTTP status code" do
        it "returns the name associated with that status code" do
          build_environment_after_exception_for_status_code(@error_code)
          get :show, code: @error_code, use_route: :rails_dynamic_errors
          controller.send(:status_name).should eq("Not Found")
        end
      end

      context "when the status code is not a valid HTTP status code" do
        it "returns 'Error'" do
          controller.env["PATH_INFO"] = "#{RailsDynamicErrors::Engine.mounted_at}/my_error"
          get :show, code: 'my_error', use_route: :rails_dynamic_errors
          controller.send(:status_name).should eq("Error")
        end
      end
    end

    context "makes the exception associated with the error (if any) available" do
      context "when the error was caused by an exception" do
        it "returns the exception" do
          build_environment_after_exception_for_status_code(@error_code)
          get :show, code: @error_code, use_route: :rails_dynamic_errors
          controller.send(:exception).should eq(@exception)
        end
      end

      context "when the error was not caused by an exception" do
        it "returns nil" do
          controller.env["PATH_INFO"] = "/errors/@error_code"
          get :show, code: @error_code, use_route: :rails_dynamic_errors
          controller.send(:exception).should eq(nil)
        end
      end
    end

    context "makes an error message available" do
      context "when the error was caused by an exception and that exception has a message" do
        it "renders that error message" do
          build_environment_after_exception_for_status_code(@error_code)
          @exception.stub(:message).and_return("Test")
          get :show, code: @error_code, use_route: :rails_dynamic_errors
          controller.send(:error_message).should eq(@exception.message)
        end
      end

      context "when the error was not caused by an exception or was but the exception doesn't have a message" do
        it "renders a default error message" do
          build_environment_after_exception_for_status_code(@error_code)
          @exception.stub(:message).and_return(nil)
          get :show, code: @error_code, use_route: :rails_dynamic_errors
          controller.send(:error_message).should eq("An error has occurred. This site administrator has been notified of this issue. We apologise for any inconvenience.")
        end
      end
    end

    context "renders an appropriate layout" do
      before(:each) do
        controller.stub(:template).and_return("show")
      end

      context "when a custom error layout is available" do
        it "uses the custom error layout" do
          build_environment_after_exception_for_status_code(@error_code)
          controller.stub(:layout).and_return("errors")
          begin
            get :show, code: @error_code, use_route: :rails_dynamic_errors
            response.should render_template("layouts/errors")
          rescue ActionView::MissingTemplate => exception
            exception.message.should =~ /Missing template layouts\/errors/
          end
        end
      end

      context "when a custom error layout is not available" do
        it "uses the application layout" do
          build_environment_after_exception_for_status_code(@error_code)
          controller.stub(:layout).and_return("application")
          get :show, code: @error_code, use_route: :rails_dynamic_errors
          response.should render_template("layouts/application")
        end
      end
    end

    context "renders an appropriate template" do
      before(:each) do
        controller.stub(:layout).and_return("application")
      end

      context "when a custom error template is available" do
        it "uses the custom error template" do
          build_environment_after_exception_for_status_code(@error_code)
          controller.stub(:template).and_return(@error_code.to_s)
          begin
            get :show, code: @error_code, use_route: :rails_dynamic_errors
            response.should render_template("rails_dynamic_errors/errors/#{@error_code}")
          rescue ActionView::MissingTemplate => exception
            exception.message.should =~ /Missing template rails_dynamic_errors\/errors\/#{@error_code}/
          end
        end
      end

      context "when a custom error template is not available" do
        it "uses the show template" do
          build_environment_after_exception_for_status_code(@error_code)
          controller.stub(:template).and_return("show")
          controller.stub(:template_exists?).and_return(false)
          get :show, code: @error_code, use_route: :rails_dynamic_errors
          response.should render_template("rails_dynamic_errors/errors/show")
        end
      end
    end
  end
end
