# frozen_string_literal: true

require 'test_helper'

module BCDD::Result::Transitions
  class TreeTest < Minitest::Test
    test '#root' do
      tree = Tree.new(:root1)

      assert_equal(:root1, tree.root.value)

      assert_equal('#<BCDD::Result::Transitions::Tree::Node id=0 children.size=0>', tree.root.inspect)
    end

    test '#root_value' do
      tree = Tree.new(:root2)

      assert_equal(:root2, tree.root_value)
    end

    test '#parent_value' do
      tree = Tree.new(:root)

      assert_equal(:root, tree.parent_value)

      tree.insert!(:child)
      tree.insert!(:grandchild)

      assert_equal(:child, tree.parent_value)

      assert_equal('#<BCDD::Result::Transitions::Tree::Node id=1 children.size=1>', tree.current.parent.inspect)
    end

    test '#current_value' do
      tree = Tree.new(:root)
      tree.insert!(:child)
      tree.insert!('grandchild')

      assert_equal('grandchild', tree.current_value)

      assert_equal('#<BCDD::Result::Transitions::Tree::Node id=2 children.size=0>', tree.current.inspect)
    end

    test '#insert' do
      tree = Tree.new(:root)
      tree.insert(:child)

      assert_same(tree.root, tree.current)
    end

    test '#insert!' do
      tree = Tree.new(:root)
      tree.insert!('child')

      refute_same(tree.root, tree.current)

      assert_equal('child', tree.current.value)
    end

    test '#move_up!' do
      tree = Tree.new('root')
      tree.insert!('child')
      tree.insert!('grandchild')

      assert_equal('grandchild', tree.current_value)

      tree.move_up!

      assert_equal('child', tree.current_value)

      tree.move_down!

      tree.move_up!(2)

      assert_equal('root', tree.current_value)

      tree.move_down!(2)
      tree.move_up!(100)

      assert_equal('root', tree.current_value)
    end

    test '#move_down!' do
      tree = Tree.new('root')
      tree.insert!('child')
      tree.insert!('grandchild')
      tree.insert!('great-grandchild')

      assert_equal('great-grandchild', tree.current_value)

      assert_predicate(tree.current, :leaf?)

      tree.move_to_root!

      assert_predicate(tree.current, :root?)

      tree.move_down!

      assert_equal('child', tree.current_value)

      assert_predicate(tree.current, :node?)
      refute_predicate(tree.current, :leaf?)

      tree.move_down!(2)

      assert_equal('great-grandchild', tree.current_value)

      tree.move_to_root!

      tree.insert!('new-child')

      tree.move_up!

      assert_equal(4, tree.size)

      tree.move_down!

      assert_equal('new-child', tree.current_value)

      tree.move_to_root!

      tree.move_down!(index: 0)

      assert_equal('child', tree.current_value)

      tree.move_down!(index: 100)

      assert_equal('child', tree.current_value)
    end

    test '#nested_ids' do
      tree = Tree.new('root')
      tree.insert!('child')
      tree.insert!('grandchild')
      tree.insert!('great-grandchild')

      tree.move_to_root!

      tree.insert!('new-child')
      tree.insert!('new-grandchild')

      tree.move_up!

      tree.insert!('new-grandchild__child')

      tree.move_to_root!

      tree.insert!('new-new-child')

      assert_equal(
        [0, [
          [1, [
            [2, [
              [3, []]
            ]]
          ]],
          [4, [
            [5, []],
            [6, []]
          ]],
          [7, []]
        ]],
        tree.nested_ids
      )

      tree.move_to_root!

      assert(tree.current.id.zero? && tree.current.value == 'root')

      tree.move_down!(index: 0)

      assert(tree.current.id == 1 && tree.current.value == 'child')

      tree.move_down!(index: 0)

      assert(tree.current.id == 2 && tree.current.value == 'grandchild')

      tree.move_down!(index: 0)

      assert(tree.current.id == 3 && tree.current.value == 'great-grandchild')

      tree.move_to_root!
      tree.move_down!(index: 1)

      assert(tree.current.id == 4 && tree.current.value == 'new-child')

      tree.move_down!(index: 0)

      assert(tree.current.id == 5 && tree.current.value == 'new-grandchild')

      tree.move_up!
      tree.move_down!

      assert(tree.current.id == 6 && tree.current.value == 'new-grandchild__child')

      tree.move_to_root!
      tree.move_down!

      assert(tree.current.id == 7 && tree.current.value == 'new-new-child')
    end
  end
end
