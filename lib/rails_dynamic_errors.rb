require 'rails_dynamic_errors/middleware/dynamic_errors'
require 'generators/rails_dynamic_errors/install_generator'

# +RailsDynamicErrors+ is the root module for the rails_dynamic_errors gem. See
# the README for more information.
module RailsDynamicErrors
  # The default mount point for the gem's engine
  DEFAULT_MOUNT_POINT = '/errors'
end

require 'rails_dynamic_errors/engine'
