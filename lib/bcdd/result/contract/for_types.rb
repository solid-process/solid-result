# frozen_string_literal: true

class BCDD::Result
  class Contract::ForTypes
    include Contract::Interface

    attr_reader :allowed_types

    TYPES_TO_IGNORE = ::Set[:_continue_, :_given_].freeze

    def initialize(types)
      @allowed_types = Array(types).map(&:to_sym).to_set.freeze
    end

    def type?(type)
      TYPES_TO_IGNORE.member?(type) || allowed_types.member?(type)
    end

    def type!(type)
      return type if type?(type)

      raise Contract::Error::UnexpectedType.build(type: type, allowed_types: allowed_types)
    end

    def type_and_value!(data)
      type!(data.type)

      nil
    end
  end
end
