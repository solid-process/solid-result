# frozen_string_literal: true

module Solid::Result::EventLogs
  class Tracking::Enabled
    attr_accessor :tree, :records, :root_started_at, :listener

    private :tree, :tree=, :records, :records=, :root_started_at, :root_started_at=, :listener, :listener=

    def exec(name, desc)
      event_log_node, scope = start(name, desc)

      result = nil

      listener.around_event_logs(scope: scope) do
        result = EnsureResult[yield]
      end

      tree.move_to_root! if event_log_node.root?

      finish(result)

      result
    rescue ::Exception => e
      err!(e, event_log_node)
    end

    def err!(exception, event_log_node)
      if event_log_node.root?
        listener.before_interruption(exception: exception, event_logs: map_event_logs)

        reset!
      end

      raise exception
    end

    def reset!
      self.tree = Tracking::EMPTY_TREE
    end

    def record(result)
      return if tree.frozen?

      track(result, time: ::Time.now.getutc)
    end

    def record_and_then(type_arg, arg)
      return yield if tree.frozen?

      type = type_arg.instance_of?(::Method) ? :method : type_arg

      current_and_then = { type: type, arg: arg }
      current_and_then[:method_name] = type_arg.name if type == :method

      tree.current.value[1] = current_and_then

      scope, and_then = tree.current_value

      result = nil

      listener.around_and_then(scope: scope, and_then: and_then) { result = yield }

      result
    end

    def reset_and_then!
      return if tree.frozen?

      tree.current.value[1] = Tracking::EMPTY_HASH
    end

    private

    def start(name, desc)
      name_and_desc = [name, desc]

      tree.frozen? ? root_start(name_and_desc) : tree.insert!(name_and_desc)

      scope = tree.current.value[0]

      listener.on_start(scope: scope)

      [tree.current, scope]
    end

    def finish(result)
      node = tree.current

      tree.move_up!

      return unless node.root?

      event_logs = map_event_logs

      result.send(:event_logs=, event_logs)

      listener.on_finish(event_logs: event_logs)

      reset!
    end

    TreeNodeValueNormalizer = ->(id, (nam, des)) { [{ id: id, name: nam, desc: des }, Tracking::EMPTY_HASH] }

    def root_start(name_and_desc)
      self.root_started_at = now_in_milliseconds

      self.listener = build_listener

      self.records = []

      self.tree = Tree.new(name_and_desc, normalizer: TreeNodeValueNormalizer)
    end

    def track(result, time:)
      record = track_record(result, time)

      records << record

      listener.on_record(record: record)

      record
    end

    def track_record(result, time)
      result_data = result.data.to_h
      result_data[:source] = result.send(:source)

      root, = tree.root_value
      parent, = tree.parent_value
      current, and_then = tree.current_value

      { root: root, parent: parent, current: current, result: result_data, and_then: and_then, time: time }
    end

    def now_in_milliseconds
      ::Process.clock_gettime(::Process::CLOCK_MONOTONIC, :millisecond)
    end

    def map_event_logs
      duration = (now_in_milliseconds - root_started_at)

      trace_id = Config.instance.trace_id.call

      ids = { tree: tree.ids, matrix: tree.ids_matrix, level_parent: tree.ids_level_parent }

      metadata = { duration: duration, trace_id: trace_id, ids: ids }

      { version: Tracking::VERSION, records: records, metadata: metadata }
    end

    def build_listener
      Config.instance.listener.new
    rescue ::StandardError => e
      err = "#{e.message} (#{e.class}); Backtrace: #{e.backtrace&.join(', ')}"

      warn("Fallback to #{Listener::Null} because registered listener raised an exception: #{err}")

      Listener::Null.new
    end
  end
end
