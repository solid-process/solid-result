# frozen_string_literal: true

class SingleEventLogsListener
  include BCDD::Result::EventLogs::Listener

  # A listener will be initialized before the first event log, and it is discarded after the last one.
  def initialize
    @buffer = []
  end

  # This method will be called before each event log block.
  # The parent event log block will be called first in the case of nested blocks.
  #
  # @param scope: {:id=>1, :name=>"SomeOperation", :desc=>"Optional description"}
  def on_start(scope:)
    scope => { id:, name:, desc: }

    @buffer << [id, "##{id} #{name} - #{desc}".chomp('- ')]
  end

  # This method will wrap all the event_logs in the same block.
  # It can be used to perform an instrumentation (measure/report) of the event_logs.
  #
  # @param scope: {:id=>1, :name=>"SomeOperation", :desc=>"Optional description"}
  def around_event_logs(scope:)
    yield
  end

  # This method will wrap each and_then call.
  # It can be used to perform an instrumentation (measure/report) of the and_then calls.
  #
  # @param scope: {:id=>1, :name=>"SomeOperation", :desc=>"Optional description"}
  # @param and_then:
  #  {:type=>:block, :arg=>:some_injected_value}
  #  {:type=>:method, :arg=>:some_injected_value, :method_name=>:some_method_name}
  def around_and_then(scope:, and_then:)
    yield
  end

  # This method will be called after each result recording/tracking.
  #
  # @param record:
  # {
  #   :root => {:id=>0, :name=>"RootOperation", :desc=>nil},
  #   :parent => {:id=>0, :name=>"RootOperation", :desc=>nil},
  #   :current => {:id=>1, :name=>"SomeOperation", :desc=>nil},
  #   :result => {:kind=>:success, :type=>:_continue_, :value=>{some: :thing}, :source=><MyProcess:0x0000000102fd6378>},
  #   :and_then => {:type=>:method, :arg=>nil, :method_name=>:some_method},
  #   :time => 2024-01-26 02:53:11.310431 UTC
  # }
  def on_record(record:)
    record => { current: { id: }, result: { kind:, type: } }

    method_name = record.dig(:and_then, :method_name)

    @buffer << [id, " * #{kind}(#{type}) from method: #{method_name}".chomp('from method: ')]
  end

  MapNestedMessages = ->(event_logs, buffer, hide_given_and_continue) do
    ids_level_parent = event_logs.dig(:metadata, :ids, :level_parent)

    messages = buffer.filter_map { |(id, msg)| "#{'   ' * ids_level_parent[id].first}#{msg}" if ids_level_parent[id] }

    messages.reject! { _1.match?(/\(_(given|continue)_\)/) } if hide_given_and_continue

    messages
  end

  # This method will be called at the end of the event_logs tracking.
  #
  # @param event_logs:
  # {
  #   :version => 1,
  #   :metadata => {
  #     :duration => 0,
  #     :trace_id => nil,
  #     :ids => {
  #       :tree => [0, [[1, []], [2, []]]],
  #       :matrix => { 0 => [0, 0], 1 => [1, 1], 2 => [2, 1]},
  #       :level_parent => { 0 => [0, 0], 1 => [1, 0], 2 => [1, 0]}
  #     }
  #   },
  #   :records => [
  #     # ...
  #   ]
  # }
  def on_finish(event_logs:)
    messages = MapNestedMessages[event_logs, @buffer, ENV['HIDE_GIVEN_AND_CONTINUE']]

    puts messages.join("\n")
  end

  # This method will be called when an exception is raised during the event_logs tracking.
  #
  # @param exception: Exception
  # @param event_logs: Hash
  def before_interruption(exception:, event_logs:)
    messages = MapNestedMessages[event_logs, @buffer, ENV['HIDE_GIVEN_AND_CONTINUE']]

    puts messages.join("\n")

    bc = ::ActiveSupport::BacktraceCleaner.new
    bc.add_filter { |line| line.gsub(__dir__.sub('/lib', ''), '').sub(/\A\//, '')}
    bc.add_silencer { |line| /lib\/bcdd\/result/.match?(line) }
    bc.add_silencer { |line| line.include?(RUBY_VERSION) }

    dir = "#{FileUtils.pwd[1..]}/"

    listener_filename = File.basename(__FILE__).chomp('.rb')

    cb = bc.clean(exception.backtrace)
    cb.each { _1.sub!(dir, '') }
    cb.reject! { _1.match?(/block \(\d levels?\) in|in `block in|internal:kernel|#{listener_filename}/) }

    puts "\nException:\n  #{exception.message} (#{exception.class})\n\nBacktrace:\n  #{cb.join("\n  ")}"
  end
end
