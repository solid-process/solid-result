# frozen_string_literal: true

module RuntimeBreaker
  Interruption = Class.new(StandardError)

  def self.try_to_interrupt(env:)
    return unless String(ENV[env]).strip.start_with?(/1|t/)

    raise Interruption, "#{env}"
  end
end
