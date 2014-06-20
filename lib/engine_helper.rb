# This module contains utility methods designed for inclusion within Rails
# engines.
module EngineHelper
  # Identifies the absolute path (i.e. '/' prefixed) at which an engine is
  # mounted within its parent Rails application.
  # @return [String] the mount path, or nil if not mounted
  def self.mounted_at
    route = Rails.application.routes.routes.detect do |route|
      route.app == self
    end
    route && route.path.spec.to_s
  end
end
