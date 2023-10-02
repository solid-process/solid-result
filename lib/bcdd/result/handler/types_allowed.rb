# frozen_string_literal: true

class BCDD::Result
  class Handler
    class TypesAllowed
      attr_reader :unchecked, :type_checker

      def initialize(type_checker, ensure_all:)
        @type_checker = type_checker

        @unchecked = type_checker.expectations.allowed_types.dup if ensure_all
      end

      def allow?(types)
        check!(types, type_checker.allow?(types))
      end

      def allow_success?(types)
        check!(types, type_checker.allow_success?(types))
      end

      def allow_failure?(types)
        check!(types, type_checker.allow_failure?(types))
      end

      def all_checked?
        unchecked.nil? || unchecked.empty?
      end

      private

      def check!(types, checked)
        unchecked.subtract(types) if checked && !all_checked?

        checked
      end
    end
  end
end
