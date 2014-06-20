require 'spec_helper'
require 'generator_spec'

describe RailsDynamicErrors::InstallGenerator do
  destination File.expand_path("../../../../dummy/tmp/", __FILE__)

  before(:each) do
    prepare_destination
    config_dir = File.expand_path("../../../../dummy/tmp/config/", __FILE__)
    FileUtils.mkdir(config_dir)
    @config_application_file = File.join(config_dir, 'application.rb')
    config_routes_file = File.join(config_dir, 'routes.rb')
    File.open(@config_application_file, 'w') { |f| f.write("module Dummy\n  class Application < Rails::Application\n  end\nend") }
    File.open(config_routes_file, 'w') { |f| f.write("Rails.application.routes.draw do\nend") }
    run_generator
  end

  it "inserts options into config/application.rb" do
    text = <<-INSERTION
    # config.rails_dynamic_errors.http_error_status_codes_to_handle = [404, 422]
    INSERTION
    File.read(@config_application_file).should include(text)
  end

  it "mounts the engine in config/routes.rb" do
    assert_file "config/routes.rb", /mount RailsDynamicErrors::Engine/
  end

  it "mounts the engine in config/routes.rb at the 'errors' path" do
    assert_file "config/routes.rb", /mount RailsDynamicErrors::Engine, at: '#{RailsDynamicErrors::DEFAULT_MOUNT_POINT}'/
  end
end
