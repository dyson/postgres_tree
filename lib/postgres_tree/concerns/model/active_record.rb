require 'active_support/concern'

module PostgresTree::ActiveRecordConcern

  extend ActiveSupport::Concern

  included do
    scope :tree_roots, -> { where(parent_id: nil) }
  end

  # Ancestors
  def ancestors
    self_and_ancestors - [self]
  end
  def self_and_ancestors
    self_and_ancestors_for(self)
  end

  # Descendents
  def descendents
    self_and_descendents - [self]
  end
  def self_and_descendents
    self_and_descendents_for(self)
  end

  # Check if ancestors, self_and_ancestors, descendents or self_and_descendents includes? object
  def method_missing(method, *args, &block)
    if method.to_s =~ /\A(.+)_include\?\z/
      self.send($1.to_sym).include? *args.first
    else
      super
    end
  end

  private

    def respond_to_missing?(method, include_private_methods = false)
      method.to_s =~ /\A(.+)_include\?\z/ || super
    end

    # Ancestors
    def self_and_ancestors_for(instance)
      self.class.where("#{self.class.table_name}.id IN (#{self_and_ancestors_sql_for(instance)})")
    end
    def self_and_ancestors_sql_for(instance)
      tree_sql = <<-SQL
        WITH RECURSIVE search_tree(id, parent_id, path) AS (
            SELECT id, parent_id, ARRAY[id]
            FROM #{self.class.table_name}
            WHERE id = #{instance.id}
          UNION ALL
            SELECT #{self.class.table_name}.id, #{self.class.table_name}.parent_id, path || #{self.class.table_name}.id
            FROM search_tree
            JOIN #{self.class.table_name} ON #{self.class.table_name}.id = search_tree.parent_id
            WHERE NOT #{self.class.table_name}.id = ANY(path)
        )
        SELECT id FROM search_tree ORDER BY path DESC
      SQL
    end

    # Descendents
    def self_and_descendents_for(instance)
      self.class.where("#{self.class.table_name}.id IN (#{self_and_descendents_sql_for(instance)})")
    end
    def self_and_descendents_sql_for(instance)
      tree_sql = <<-SQL
        WITH RECURSIVE search_tree(id, path) AS (
            SELECT id, ARRAY[id]
            FROM #{self.class.table_name}
            WHERE id = #{instance.id}
          UNION ALL
            SELECT #{self.class.table_name}.id, path || #{self.class.table_name}.id
            FROM search_tree
            JOIN #{self.class.table_name} ON #{self.class.table_name}.parent_id = search_tree.id
            WHERE NOT #{self.class.table_name}.id = ANY(path)
        )
        SELECT id FROM search_tree ORDER BY path
      SQL
    end
end
