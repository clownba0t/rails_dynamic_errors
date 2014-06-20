require 'rails_dynamic_errors/middleware/dynamic_errors'
require 'rails_dynamic_errors/engine'
require 'generators/rails_dynamic_errors/install_generator'
require 'active_support/dependencies'

module RailsDynamicErrors
  mattr_accessor :app_root

  def self.setup
    yield self
  end
end
