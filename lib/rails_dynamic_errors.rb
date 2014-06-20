require 'rails_dynamic_errors/middleware/dynamic_errors'
require 'rails_dynamic_errors/engine'
require 'active_support/dependencies'

module RailsDynamicErrors
  mattr_accessor :app_root

  def self.setup
    yield self
  end
end
