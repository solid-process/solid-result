# frozen_string_literal: true

module BCDD::Result::Transitions
  module Tracking::Disabled
    def self.exec(_name, _desc)
      EnsureResult[yield]
    end

    def self.err!(err)
      raise err
    end

    def self.reset!; end

    def self.record(result); end

    def self.record_and_then(_type, _data)
      yield
    end

    def self.reset_and_then!; end

    class << self
      private

      def start(name, desc); end

      def finish(result); end
    end
  end
end
