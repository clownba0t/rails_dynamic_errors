require 'spec_helper'

describe RailsDynamicErrors::Engine do
  describe "::mounted_at" do
    it "returns the path at which the engine is mounted within a Rails application" do
      RailsDynamicErrors::Engine.mounted_at.should eq(RailsDynamicErrors::DEFAULT_MOUNT_PATH)
    end

    it "creates a set of namespaced configuration options in the Rails application it is mounted within" do
       Rails.application.config.rails_dynamic_errors.class.should eq(ActiveSupport::OrderedOptions)
    end
  end
end
