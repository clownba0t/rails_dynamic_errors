require 'spec_helper'

describe RailsDynamicErrors::DynamicErrors do
  before(:each) do
    # Engine this middleware is contained within is mountable, so we have to take
    # that into account
    RailsDynamicErrors::Engine.stub(:mounted_at).and_return('/errors')

    # Prevent the actual Rails application from processing the request
    Rails.application.routes.stub(:call)
  end

  context "on initialisation" do
    it "raises an error if HTTP error codes to handle is not an array" do
      expect { RailsDynamicErrors::DynamicErrors.new(@app, nil) }.to raise_error(ArgumentError)
    end
  end

  context "when an exception bubbles up from the Rails application or a middleware further down the stack" do
    before(:each) do
      @exception = ActionController::RoutingError.new("Not Found")
      @app = double("app")
      @app.stub(:call) { raise @exception }
      @input_env = env_for('/valid_route/-1')
    end

    context "and it is configured to handle the HTTP status code that exception is associated with" do
      before(:each) do
        @middleware = RailsDynamicErrors::DynamicErrors.new(@app, [ 404 ])
      end

      it "updates the environment of the request to point to a path that will generate a dynamic error page for the status code" do
        (code, output_env) = @middleware.call(@input_env)
        @input_env['PATH_INFO'].should eq('/errors/404')
      end

      it "updates the environment of the request with the exception that caused the error" do
        (code, output_env) = @middleware.call(@input_env)
        @input_env['action_dispatch.exception'].should eq(@exception)
      end

      it "calls the router of the Rails application it's embedded within to process the updated environment" do
        Rails.application.routes.should_receive(:call).with(@input_env)
        (code, output_env) = @middleware.call(@input_env)
      end
    end

    context "and it is not configured to handle the HTTP status code that exception is associated with" do
      it "re-raises the exception" do
        middleware = RailsDynamicErrors::DynamicErrors.new(@app, [])
        expect { middleware.call(@input_env) }.to raise_error(@exception)
      end
    end
  end

  context "when the response received has a 404 status code and X-Cascade header set to 'pass'" do
    before(:each) do
      @app = double("app")
      @app.stub(:call).and_return([404, {'X-Cascade' => 'pass'}, ['Not Found']])
      @input_env = env_for('/invalid_route')
    end

    context "and it is configured to handle 404 status codes" do
      before(:each) do
        @middleware = RailsDynamicErrors::DynamicErrors.new(@app, [ 404 ])
      end

      it "updates the environment of the request to point to a path that will generate a dynamic error page for the status code" do
        (code, output_env) = @middleware.call(@input_env)
        @input_env['PATH_INFO'].should eq('/errors/404')
      end

      it "updates the environment of the request with a routing exception" do
        (code, output_env) = @middleware.call(@input_env)
        @input_env['action_dispatch.exception'].class.should eq(ActionController::RoutingError)
      end

      it "calls the router of the Rails application it's embedded within to process the updated environment" do
        Rails.application.routes.should_receive(:call).with(@input_env)
        (code, output_env) = @middleware.call(@input_env)
      end
    end

    context "and it is not configured to handle 404 status codes" do
      it "passes on the response" do
        middleware = RailsDynamicErrors::DynamicErrors.new(@app, [])
        response = middleware.call(@input_env)
        response.should eq([404, {'X-Cascade' => 'pass'}, ['Not Found']])
      end
    end
  end

  def env_for(url, options = {})
    Rack::MockRequest.env_for(url, options)
  end
end
