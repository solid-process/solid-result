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
    ids_level_parent = transitions.dig(:metadata, :ids, :level_parent)

    messages = buffer.filter_map { |(id, msg)| "#{'   ' * ids_level_parent[id].first}#{msg}" if ids_level_parent[id] }

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

    dir = "#{FileUtils.pwd[1..]}/"

    cb = bc.clean(exception.backtrace)
    cb.each { _1.sub!(dir, '') }
    cb.reject! { _1.match?(/block \(\d levels?\) in|in `block in|internal:kernel/) }

    puts "\nException:\n  #{exception.message} (#{exception.class})\n\nBacktrace:\n  #{cb.join("\n  ")}"
  end
end
