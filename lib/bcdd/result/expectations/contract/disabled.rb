# frozen_string_literal: true

class BCDD::Result::Expectations
  module Contract::Disabled
    extend Contract::Interface

    EMPTY_SET = ::Set.new.freeze

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
