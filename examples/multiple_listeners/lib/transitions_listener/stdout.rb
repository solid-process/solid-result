# frozen_string_literal: true

class TransitionsListener::Stdout
  include BCDD::Result::Transitions::Listener

  def initialize
    @buffer = []
  end

  def on_start(scope:)
    scope => { id:, name:, desc: }

    @buffer << [id, "##{id} #{name} - #{desc}".chomp('- ')]
  end

  def on_record(record:)
    record => { current: { id: }, result: { kind:, type: } }

    method_name = record.dig(:and_then, :method_name)

    @buffer << [id, " * #{kind}(#{type}) from method: #{method_name}".chomp('from method: ')]
  end

  MapNestedMessages = ->(transitions, buffer, hide_given_and_continue) do
    ids_matrix = transitions.dig(:metadata, :ids_matrix)

    messages = buffer.filter_map { |(id, msg)| "#{'   ' * ids_matrix[id].last}#{msg}" if ids_matrix[id] }

    messages.reject! { _1.match?(/\(_(given|continue)_\)/) } if hide_given_and_continue

    messages
  end

  def on_finish(transitions:)
    messages = MapNestedMessages[transitions, @buffer, ENV['HIDE_GIVEN_AND_CONTINUE']]

    puts messages.join("\n")
  end

  def before_interruption(exception:, transitions:)
    messages = MapNestedMessages[transitions, @buffer, ENV['HIDE_GIVEN_AND_CONTINUE']]

    puts messages.join("\n")

    bc = ::ActiveSupport::BacktraceCleaner.new
    bc.add_filter { |line| line.gsub(__dir__.sub('/lib', ''), '').sub(/\A\//, '')}
    bc.add_silencer { |line| /lib\/bcdd\/result/.match?(line) }
    bc.add_silencer { |line| line.include?(RUBY_VERSION) }

    backtrace = bc.clean(exception.backtrace)

    puts "\nException: #{exception.message} (#{exception.class}); Backtrace: #{backtrace.join(", ")}"
  end
end
