require 'spec_helper'

describe RailsDynamicErrors do
  before(:all) do
    Rails.application.config.action_dispatch.show_exceptions = true
  end

  context "when it is configured to handle 404 errors" do
    context "when a invalid route is provided" do
      it "displays a 404 error page" do
        visit '/bogus_route'
        page.should have_content("404 Not Found")
      end
    end

    context "when a valid route is provided but the resource it refers to doesn't exist" do
      it "displays a 404 error page" do
        visit '/things/-1'
        page.should have_content("404 Not Found")
      end
    end

    it "does not interfere with valid requests" do
      thing = Thing.create!(:name => "Test")
      visit thing_path(thing)
      page.should have_content("Name: Test")
    end
  end

  context "when it is not configured to handle 500 errors" do
    context "when an internal server error is encountered" do
      it "displays a 500 error page" do
        visit '/booms/1'
        page.should_not have_content("500 Internal Server Error")
      end
    end

    it "does not interfere with valid requests" do
      thing = Thing.create!(:name => "Test")
      visit thing_path(thing)
      page.should have_content("Name: Test")
    end
  end
end
