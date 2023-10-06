# frozen_string_literal: true

class BCDD::Result
  class Handler
    class TypesAllowed
      attr_reader :unchecked, :type_checker

      def initialize(type_checker)
        @type_checker = type_checker

        @expectations = type_checker.expectations

        @unchecked = @expectations.allowed_types.dup
      end

      def allow?(types)
        check!(types, type_checker.allow?(types))
      end

      def allow_success?(types)
        unchecked.subtract(@expectations.success.allowed_types) if types.empty?

        check!(types, type_checker.allow_success?(types))
      end

      def allow_failure?(types)
        unchecked.subtract(@expectations.failure.allowed_types) if types.empty?

        check!(types, type_checker.allow_failure?(types))
      end

      def all_checked?
        unchecked.empty?
      end

      private

      def check!(types, checked)
        unchecked.subtract(types) unless all_checked?

        checked
      end
    end
  end
end
