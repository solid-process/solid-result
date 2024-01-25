# frozen_string_literal: true

module BCDD::Result::Transitions
  class Tracking::Enabled
    attr_accessor :tree, :records, :root_started_at

    private :tree, :tree=, :records, :records=, :root_started_at, :root_started_at=

    def exec(name, desc)
      start(name, desc)

      transition_node = tree.current

      result = EnsureResult[yield]

      tree.move_to_root! if transition_node.root?

      finish(result)

      result
    end

    def reset!
      self.tree = Tracking::EMPTY_TREE
    end

    def record(result)
      return if tree.frozen?

      track(result, time: ::Time.now.getutc)
    end

    def record_and_then(type_arg, arg)
      type = type_arg.instance_of?(::Method) ? :method : type_arg

      unless tree.frozen?
        current_and_then = { type: type, arg: arg }
        current_and_then[:method_name] = type_arg.name if type == :method

        tree.current.value[1] = current_and_then
      end

      yield
    end

    def reset_and_then!
      return if tree.frozen?

      tree.current.value[1] = Tracking::EMPTY_HASH
    end

    private

    def start(name, desc)
      name_and_desc = [name, desc]

      tree.frozen? ? root_start(name_and_desc) : tree.insert!(name_and_desc)
    end

    def finish(result)
      node = tree.current

      tree.move_up!

      return unless node.root?

      duration = (now_in_milliseconds - root_started_at)

      metadata = { duration: duration, tree_map: tree.nested_ids }

      result.send(:transitions=, version: Tracking::VERSION, records: records, metadata: metadata)

      reset!
    end

    TreeNodeValueNormalizer = ->(id, (nam, des)) { [{ id: id, name: nam, desc: des }, Tracking::EMPTY_HASH] }

    def root_start(name_and_desc)
      self.root_started_at = now_in_milliseconds

      self.records = []

      self.tree = Tree.new(name_and_desc, normalizer: TreeNodeValueNormalizer)
    end

    def track(result, time:)
      result_data = result.data.to_h
      result_data[:source] = result.send(:source)

      root, = tree.root_value
      parent, = tree.parent_value
      current, and_then = tree.current_value

      records << { root: root, parent: parent, current: current, result: result_data, and_then: and_then, time: time }
    end

    def now_in_milliseconds
      ::Process.clock_gettime(::Process::CLOCK_MONOTONIC, :millisecond)
    end
  end
end
