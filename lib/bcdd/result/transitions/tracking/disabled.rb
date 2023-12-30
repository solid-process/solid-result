# frozen_string_literal: true

module BCDD::Result::Transitions
  module Tracking::Disabled
    def self.start(name:, desc:); end

    def self.finish(result:); end

    def self.reset!; end

    def self.record(result); end

    def self.record_and_then(_type, _data, _subject)
      yield
    end
  end
end
