# frozen_string_literal: true

module BCDD::Result
  class Base
    attr_reader :type, :value

    def initialize(type:, value:)
      @type = type.to_sym
      @value = value
    end

    def success?(_type = nil)
      raise Error::NotImplemented
    end

    def failure?(_type = nil)
      raise Error::NotImplemented
    end

    def value_or(&_block)
      raise Error::NotImplemented
    end

    def ==(other)
      self.class == other.class && type == other.type && value == other.value
    end
    alias eql? ==

    def hash
      [self.class, type, value].hash
    end

    def inspect
      format('#<%<class_name>s type=%<type>p value=%<value>p>', class_name: self.class.name, type: type, value: value)
    end

    def on(*types)
      raise Error::MissingTypeArgument if types.empty?

      tap { yield(value, type) if expected_type?(types) }
    end

    def on_success(*types)
      tap { yield(value, type) if success? && allowed_to_handle?(types) }
    end

    def on_failure(*types)
      tap { yield(value, type) if failure? && allowed_to_handle?(types) }
    end

    def and_then
      return self if failure?

      result = yield(value)

      return result if result.is_a?(Base)

      raise Error::UnexpectedBlockResult
    end

    alias data value
    alias data_or value_or
    alias on_type on

    private

    def expected_type?(types)
      types.any?(type)
    end

    def allowed_to_handle?(types)
      types.empty? || expected_type?(types)
    end
  end
end
