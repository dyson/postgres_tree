# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

# Below for issue: can't use fixtures with a created engine #4971
# https://github.com/rails/rails/issues/4971

# Drop all tables
ActiveRecord::Base.establish_connection
ActiveRecord::Base.connection.execute("drop schema public cascade;")
ActiveRecord::Base.connection.execute("create schema public;")

# Run any available migration (part of issue above but test db isn't migrating...)
# Should just load schema but haven't looked up how to do that.
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

# I had to add in /dummy/test to the path to find the fixtures correcty.
# No one else had mentioned this but it works for me.
ActiveSupport::TestCase.fixture_path = File.expand_path("../dummy/test/fixtures", __FILE__)

class ActiveSupport::TestCase
  fixtures :all
end

# Other issues if using a mountable engine around namespaces can also be resolved
# with information in the above github issue.
