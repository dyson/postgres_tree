$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "postgres_tree/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "postgres_tree"
  s.version     = PostgresTree::VERSION
  s.authors     = ["Dyson Simmons"]
  s.email       = ["dysonsimmons@gmail.com"]
  s.homepage    = "https://github.com/dyson/postgres_tree"
  s.summary     = "ActiveRecord tree structures using PostgreSQL"
  s.description = "Access to an activerecord models ancestors and descendents in one query."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0"

  s.add_development_dependency "pg"
  s.add_development_dependency "coveralls"
end
