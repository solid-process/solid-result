# frozen_string_literal: true

class Solid::Result
  class Contract::ForTypes
    include Contract::Interface

    attr_reader :allowed_types

    def initialize(types)
      @allowed_types = Array(types).map(&:to_sym).to_set.freeze
    end

    def type?(type)
      IgnoredTypes.include?(type) || allowed_types.member?(type)
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
