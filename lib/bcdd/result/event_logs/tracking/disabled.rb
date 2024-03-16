# frozen_string_literal: true

module BCDD::Result::EventLogs
  module Tracking::Disabled
    def self.exec(_name, _desc)
      EnsureResult[yield]
    end

    def self.record(result); end

    def self.record_and_then(_type, _data)
      yield
    end
  end
end
