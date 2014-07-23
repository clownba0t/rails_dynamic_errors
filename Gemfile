source "https://rubygems.org"

# Enable Rails version to use to be supplied via the environment. Only sets the
# Rails version if the environment variable is available, otherwise relies on
# the dependency specified in the gemspec file. (This is why this code must
# appear before the gemspec call, as only the first call to 'gem' with a given
# gem name takes effect.)
rails_version = ENV["RAILS_VERSION"]

if rails_version
  if "master" == rails_version
    gem "rails",  {github: "rails/rails"}
  else
    gem "rails", "~> #{rails_version}"
  end
end

# Declare your gem's dependencies in rails_dynamic_errors.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'
