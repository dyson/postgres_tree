require 'test_helper'

class PersonTest < ActiveSupport::TestCase

  # Test that we actually have fixtures loaded
  test "person fixtures loaded" do
    record = Person.first
    refute record == nil
  end

  # Base methods
  test "responds to all methods" do
    record = Person.first
    assert_respond_to record, :ancestors
    assert_respond_to record, :self_and_ancestors
    assert_respond_to record, :descendents
    assert_respond_to record, :self_and_descendents
  end

  # Magic methods with _includes?
  test "respond to all magic methods" do
    record = Person.first
    assert_respond_to record, :ancestors_include?
    assert_respond_to record, :self_and_ancestors_include?
    assert_respond_to record, :descendents_include?
    assert_respond_to record, :self_and_descendents_include?
  end

  # Scopes
  test "tree_roots scope" do
    assert_equal 1, Person.tree_roots.count
  end

  # Ancestors
  # Test when we have ancestors
  test "dad ancestors" do
    grandad = Person.find 1
    dad = Person.find 2
    ancestors = dad.ancestors
    assert_equal 1, ancestors.count
    assert ancestors.include? grandad

    assert dad.ancestors_include? grandad

    ancestors = dad.self_and_ancestors
    assert_equal 2, ancestors.count
    assert ancestors.include? grandad
    assert ancestors.include? dad

    assert dad.self_and_ancestors_include? grandad
    assert dad.self_and_ancestors_include? dad
  end
  # Test when we have no ancestors
  test "grandad ancestors" do
    grandad = Person.find 1
    ancestors = grandad.ancestors
    assert_equal 0, ancestors.count
  end

  # Descendents
  # Test when we have descendents
  test "dad descendents" do
    dad = Person.find 2
    son = Person.find 3
    descendents = dad.descendents
    assert_equal 1, descendents.count
    assert_equal son, descendents.first

    assert dad.descendents_include? son

    descendents = dad.self_and_descendents
    assert_equal 2, descendents.count
    assert descendents.include? dad
    assert descendents.include? son

    assert dad.self_and_descendents_include? dad
    assert dad.self_and_descendents_include? son
  end
  # Test when we have no descendents
  test "son descendents" do
    son = Person.find 3
    descendents = son.descendents
    assert_equal 0, descendents.count
  end

end
