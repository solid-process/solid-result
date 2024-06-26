# frozen_string_literal: true

class Solid::Result
  module EventLogs
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

      Ids = ->(node) { [node.id, node.children.map(&Ids)] }

      def ids
        Ids[root]
      end

      def ids_list
        ids.flatten
      end

      IdsMatrix = ->(tree, row, col, memo, previous) do
        last_row = previous[0]

        tree.each_with_index do |node, index|
          row = [(index + 1), last_row].max

          id, leaf = node

          memo[id] = previous == [row, col] ? [row, col + 1] : [row, col]

          previous = memo[id]

          IdsMatrix[leaf, row, col + 1, memo, previous]
        end
      end

      def ids_matrix
        current = [0, 0]

        memo = { 0 => current }

        IdsMatrix[ids[1], 1, 1, memo, current]

        memo
      end

      IdsLevelParent = ->((id, node), parent = 0, level = 0, memo = {}) do
        memo[id] = [level, parent]

        node.each { |leaf| IdsLevelParent[leaf, id, level + 1, memo] }

        memo
      end

      def ids_level_parent
        IdsLevelParent[ids]
      end
    end
  end
end
