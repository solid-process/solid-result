# frozen_string_literal: true

module BCDD::Result::Transitions
  module Tracking::Disabled
    def self.start(id:); end

    def self.finish(id:, result:); end

    def self.reset!; end

    def self.record(result); end
  end
end
