class BoomsController < ApplicationController
  # Force a 500 error to be raised (for integration testing)
  def show
    raise Exception.new("Oh no!")
  end
end
