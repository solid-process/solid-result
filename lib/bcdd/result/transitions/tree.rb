# frozen_string_literal: true

class BCDD::Result
  module Transitions
    class Tree
      class Node
        attr_reader :id, :value, :parent, :normalizer, :children

        def initialize(value, parent:, id:, normalizer:)
          @normalizer = normalizer

          @id = id
          @value = normalizer.call(id, value)
          @parent = parent

          @children = []
        end

        def insert(value, id:)
          node = self.class.new(value, parent: self, id: id, normalizer: normalizer)

          @children << node

          node
        end

        def root?
          parent.nil?
        end

        def leaf?
          children.empty?
        end

        def node?
          !leaf?
        end

        def inspect
          "#<#{self.class.name} id=#{id} children.size=#{children.size}>"
        end
      end

      attr_reader :size, :root, :current

      def initialize(value, normalizer: ->(_id, val) { val })
        @size = 0

        @root = Node.new(value, parent: nil, id: size, normalizer: normalizer)

        @current = root
      end

      def root_value
        root.value
      end

      def parent_value
        current.parent&.value || root_value
      end

      def current_value
        current.value
      end

      def insert(value)
        @size += 1

        current.insert(value, id: size)
      end

      def insert!(value)
        move_to! insert(value)
      end

      def move_to!(node)
        tap { @current = node }
      end

      def move_up!(level = 1)
        tap { level.times { move_to!(current.parent || root) } }
      end

      def move_down!(level = 1, index: -1)
        tap { level.times { current.children[index].then { |child| move_to!(child) if child } } }
      end

      def move_to_root!
        move_to!(root)
      end

      NestedIds = ->(node) { [node.id, node.children.map(&NestedIds)] }

      def nested_ids
        NestedIds[root]
      end

      IdsMatrix = ->(tree, row, col, ids, previous) do
        last_row = previous[0]

        tree.each_with_index do |node, index|
          row = [(index + 1), last_row].max

          id, leaf = node

          ids[id] = previous == [row, col] ? [row, col + 1] : [row, col]

          previous = ids[id]

          IdsMatrix[leaf, row, col + 1, ids, previous]
        end
      end

      def ids_matrix
        current = [0, 0]

        ids = { 0 => current }

        IdsMatrix[nested_ids[1], 1, 1, ids, current]

        ids
      end
    end
  end
end
