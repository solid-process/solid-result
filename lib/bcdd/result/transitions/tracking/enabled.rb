# frozen_string_literal: true

module BCDD::Result::Transitions
  class Tracking::Enabled
    attr_accessor :root, :parent, :current, :parents, :records, :current_and_then

    private :root, :root=, :parent, :parent=, :current, :current=
    private :parents, :parents=, :records, :records=, :current_and_then, :current_and_then=

    def start(id:, name:, desc:)
      root.frozen? and return root_start(id, name, desc)

      self.parent = current if parent[:id] != current[:id]
      self.current = { id: id, name: name, desc: desc }

      parents[id] = parent
    end

    def finish(id:, result:)
      self.current = parents[id]
      self.parent = parents.fetch(current[:id])

      return if root && root[:id] != id

      result.send(:transitions=, records: records, version: Tracking::VERSION)

      reset!
    end

    def reset!
      self.root = Tracking::EMPTY_HASH
      self.parent = Tracking::EMPTY_HASH
      self.current = Tracking::EMPTY_HASH
      self.parents = Tracking::EMPTY_HASH
      self.records = Tracking::EMPTY_ARRAY

      reset_current_and_then!
    end

    def record(result)
      return if root.frozen?

      track(result, time: ::Time.now.getutc)
    end

    def record_and_then(type_arg, arg, subject)
      type = type_arg.instance_of?(::Method) ? :method : type_arg

      self.current_and_then = { type: type, arg: arg, subject: subject }

      current_and_then[:method_name] = type_arg.name if type == :method

      result = yield

      reset_current_and_then!

      result
    end

    private

    def root_start(id, name, desc)
      self.current = { id: id, name: name, desc: desc }
      self.parent = current
      self.root = current

      self.parents = { current[:id] => current }
      self.records = []

      reset_current_and_then!
    end

    def track(result, time:)
      result = result.data.to_h

      and_then = current_and_then

      record =
        { root: root, parent: parent, current: current, result: result, and_then: and_then, time: time }

      records << record
    end

    def reset_current_and_then!
      self.current_and_then = Tracking::EMPTY_HASH
    end
  end
end
