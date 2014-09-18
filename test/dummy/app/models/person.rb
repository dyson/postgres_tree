class Person < ActiveRecord::Base
  include PostgresTree::ActiveRecordConcern
end
