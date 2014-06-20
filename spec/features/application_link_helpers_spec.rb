require 'spec_helper'

describe RailsDynamicErrors::Engine do
  it "should have access to application helpers" do
    visit '/errors/url_helpers'
    page.should have_link('New Thing', :href => new_thing_path)
  end
end
