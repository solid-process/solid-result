# frozen_string_literal: true

module BCDD::Result::Expectations::Contract
  module Disabled
    extend Interface

    EMPTY_SET = Set.new.freeze

    def self.allowed_types
      EMPTY_SET
    end

    def self.type?(_type)
      true
    end

    def self.type!(type)
      type
    end

    def self.type_and_value!(_data); end

    private_constant :EMPTY_SET
  end
end
