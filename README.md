### Postgres Tree: ActiveRecord tree structures using PostgreSQL.

Include PostgresTree::ActiveRecordConcern in your models along with a parent_id field and get access to ancestors and descendents in one query.

[![Build Status](https://travis-ci.org/dyson/postgres_tree.svg?branch=master)](https://travis-ci.org/dyson/postgres_tree) [![Coverage Status](https://img.shields.io/coveralls/dyson/postgres_tree.svg)](https://coveralls.io/r/dyson/postgres_tree?branch=master)

----

#### Requirements

Gems:
* activerecord
* pg

Tested using rails ~> 4.0.0

#### Installation

##### Gemfile

Add to your Gemfile:

```ruby
gem 'awesome-tree', git: 'https://github.com/dyson/awesome-tree.git', tag: 'v0.0.2'
```

##### Migration

Add a parent_id field to your model via a migration. For example, a roles table:

```ruby
class AddParentIdToRoles < ActiveRecord::Migration
  def change
    change_table :roles do |t|
      t.integer :parent_id
    end

    add_index :roles, [:parent_id]
  end
end
```

##### Model

```ruby
class Role < ActiveRecord::Base

  awesome_treeify

  # Associations for tree
  belongs_to :parent, class_name: "Role"
  has_many :children, class_name: "Role", foreign_key: 'parent_id'

end

```

#### Methods

* role.**ancestors** - Get all ancestors.
* role.**self_and_ancestors** - Get all ancestors and include self in the returned result.
* role.**descendents** - Get all descendents.
* role.**self_and_descendents** - Get all descendents and include self in the returned result.

There is also an **_include?** method missing which returns **true** of **false**:

* role.**ancestors_include?** (object of same type)
* role.**self_and_ancestors_include?** (object of same type)
* role.**descendents_include?** (object of same type)
* role.**self_and_descendents_include?** (object of same type)

Using the self referencing belongs and has_many as above, you also get get the parent and children:

* role.**parent**
* role.**children**
* role.**children_include?**

#### Scopes

A named scope called root is also added to the model to obtain all root records:

```ruby
root_role = Role.root
```

#### Usage example

```ruby
irb(main):001:0> parent = Role.find 2
  Role Load (3.7ms)  SELECT "roles".* FROM "roles" WHERE "roles"."id" = $1 LIMIT 1  [["id", 2]]
=> #<Role id: 2, name: "Parent", parent_id: 1>
irb(main):002:0> parent.ancestors
  Role Load (2.7ms)  SELECT "roles".* FROM "roles" WHERE (roles.id IN ( WITH RECURSIVE search_tree(id, parent_id, path) AS (
 SELECT id, parent_id, ARRAY[id]
 FROM roles
 WHERE id = 2
 UNION ALL
 SELECT roles.id, roles.parent_id, path || roles.id
 FROM search_tree
 JOIN roles ON roles.id = search_tree.parent_id
 WHERE NOT roles.id = ANY(path)
 )
 SELECT id FROM search_tree ORDER BY path DESC
))
=> [#<Role id: 1, name: "Grandparent", parent_id: nil>]

irb(main):003:0> parent.self_and_ancestors
  Role Load (1.4ms)  SELECT "roles".* FROM "roles" WHERE (roles.id IN ( WITH RECURSIVE search_tree(id, parent_id, path) AS (
 SELECT id, parent_id, ARRAY[id]
 FROM roles
 WHERE id = 2
 UNION ALL
 SELECT roles.id, roles.parent_id, path || roles.id
 FROM search_tree
 JOIN roles ON roles.id = search_tree.parent_id
 WHERE NOT roles.id = ANY(path)
 )
 SELECT id FROM search_tree ORDER BY path DESC
))
=> #<ActiveRecord::Relation [#<Role id: 1, name: "Grandparent", parent_id: nil>, #<Role id: 2, name: "Parent", parent_id: 1>]>

irb(main):004:0> parent.descendents
  Role Load (1.4ms)  SELECT "roles".* FROM "roles" WHERE (roles.id IN ( WITH RECURSIVE search_tree(id, path) AS (
 SELECT id, ARRAY[id]
 FROM roles
 WHERE id = 2
 UNION ALL
 SELECT roles.id, path || roles.id
 FROM search_tree
 JOIN roles ON roles.parent_id = search_tree.id
 WHERE NOT roles.id = ANY(path)
 )
 SELECT id FROM search_tree ORDER BY path
))
=> [#<Role id: 3, name: "Child", parent_id: 2>]

irb(main):005:0> parent.self_and_descendents
  Role Load (1.4ms)  SELECT "roles".* FROM "roles" WHERE (roles.id IN ( WITH RECURSIVE search_tree(id, path) AS (
 SELECT id, ARRAY[id]
 FROM roles
 WHERE id = 2
 UNION ALL
 SELECT roles.id, path || roles.id
 FROM search_tree
 JOIN roles ON roles.parent_id = search_tree.id
 WHERE NOT roles.id = ANY(path)
 )
 SELECT id FROM search_tree ORDER BY path
))
=> #<ActiveRecord::Relation [#<Role id: 2, name: "Parent", parent_id: 1>, #<Role id: 3, name: "Child", parent_id: 2>]>

irb(main):006:0> child = Role.find 3
  Role Load (0.6ms)  SELECT "roles".* FROM "roles" WHERE "roles"."id" = $1 LIMIT 1  [["id", 3]]
=> #<Role id: 3, name: "Child", parent_id: 2>

irb(main):007:0> parent.descendents_include? child
  Role Load (0.9ms)  SELECT "roles".* FROM "roles" WHERE (roles.id IN ( WITH RECURSIVE search_tree(id, path) AS (
 SELECT id, ARRAY[id]
 FROM roles
 WHERE id = 2
 UNION ALL
 SELECT roles.id, path || roles.id
 FROM search_tree
 JOIN roles ON roles.parent_id = search_tree.id
 WHERE NOT roles.id = ANY(path)
 )
 SELECT id FROM search_tree ORDER BY path
))
=> true

irb(main):008:0> parent.self_and_descendents_include? child
  Role Load (0.9ms)  SELECT "roles".* FROM "roles" WHERE (roles.id IN ( WITH RECURSIVE search_tree(id, path) AS (
 SELECT id, ARRAY[id]
 FROM roles
 WHERE id = 2
 UNION ALL
 SELECT roles.id, path || roles.id
 FROM search_tree
 JOIN roles ON roles.parent_id = search_tree.id
 WHERE NOT roles.id = ANY(path)
 )
 SELECT id FROM search_tree ORDER BY path
))
=> true

irb(main):009:0> parent.ancestors_include? child
  Role Load (1.5ms)  SELECT "roles".* FROM "roles" WHERE (roles.id IN ( WITH RECURSIVE search_tree(id, parent_id, path) AS (
 SELECT id, parent_id, ARRAY[id]
 FROM roles
 WHERE id = 2
 UNION ALL
 SELECT roles.id, roles.parent_id, path || roles.id
 FROM search_tree
 JOIN roles ON roles.id = search_tree.parent_id
 WHERE NOT roles.id = ANY(path)
 )
 SELECT id FROM search_tree ORDER BY path DESC
))
=> false

irb(main):010:0> parent.self_and_ancestors_include? child
  Role Load (1.5ms)  SELECT "roles".* FROM "roles" WHERE (roles.id IN ( WITH RECURSIVE search_tree(id, parent_id, path) AS (
 SELECT id, parent_id, ARRAY[id]
 FROM roles
 WHERE id = 2
 UNION ALL
 SELECT roles.id, roles.parent_id, path || roles.id
 FROM search_tree
 JOIN roles ON roles.id = search_tree.parent_id
 WHERE NOT roles.id = ANY(path)
 )
 SELECT id FROM search_tree ORDER BY path DESC
))
=> false
```

#### License

The MIT License (MIT)

Copyright 2014 Dyson Simmons

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.




