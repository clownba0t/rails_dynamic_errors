require 'spec_helper'

describe "rails_dynamic_errors/errors/show.html.erb" do
  before(:each) do
    view.stub(:status_code).and_return("404")
    view.stub(:status_name).and_return("Not Found")
    view.stub(:error_message).and_return("Sorry, we couldn't find what you're looking for.")
  end

  it "displays the error code" do
    render
    Capybara.string(rendered).should have_content("404")
  end

  it "displays the error name" do
    render
    Capybara.string(rendered).should have_content("Not Found")
  end

  it "displays the error message" do
    render
    Capybara.string(rendered).should have_content("Sorry, we couldn't find what you're looking for.")
  end
end
