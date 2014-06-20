$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails_dynamic_errors/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails_dynamic_errors"
  s.version     = RailsDynamicErrors::VERSION
  s.authors     = ["Daniel Carter"]
  s.email       = ["clownba0t@gmail.com"]
  s.homepage    = "http://www.github.com/clownba0t/rails_dynamic_errors"
  s.summary     = "rails_dynamic_errors #{s.version}"
  s.description = "Dynamic error page generation in Rails"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 4.0.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "generator_spec"
end
