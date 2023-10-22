# frozen_string_literal: true

class BCDD::Result::Context
  class Accumulator
    module Enabled
      private

      def _ResultAcc
        @_ResultAcc ||= Accumulator.new
      end
    end

    EMPTY_DATA = {}.freeze

    def self.if_enabled(object)
      yield(object.send(:_ResultAcc)) if object.is_a?(Enabled)
    end

    def self.data(object)
      if_enabled(object, &:data) || {}
    end

    def self.data!(object, value)
      if_enabled(object) { |acc| acc.data!(value) } || {}
    end

    attr_reader :data

    def initialize
      @data = {}
    end

    def data!(value)
      data.merge!(value)
      data
    end
  end

  private_constant :Accumulator
end
