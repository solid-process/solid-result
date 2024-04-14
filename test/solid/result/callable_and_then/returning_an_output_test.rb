# frozen_string_literal: true

require 'test_helper'

class Solid::Result
  class CallableAndThenReturninAnOutputTest < Minitest::Test
    include SolidResultEventLogAssertions

    module NormalizeEmail
      extend ::Solid::Output.mixin

      def self.call(arg)
        Solid::Result.event_logs(name: 'NormalizeEmail') do
          input = arg[:input]

          input.is_a?(::String) or return Failure(:invalid_input, message: 'input must be a String')

          Success(:normalized_input, input: input.downcase.strip)
        end
      end
    end

    module EmailNormalization
      extend Solid::Result.mixin

      def self.call(input)
        Solid::Result.event_logs(name: 'EmailNormalization') do
          Given(input: input)
            .and_then!(NormalizeEmail)
        end
      end
    end

    test 'results from different sources' do
      Solid::Result.config.feature.enable!(:and_then!)

      result1 = EmailNormalization.call(nil)

      assert_event_logs(result1, size: 2)

      assert(result1.failure?(:invalid_input))
      assert_equal({ message: 'input must be a String' }, result1.value)
      assert_kind_of(::Solid::Output, result1)

      result2 = EmailNormalization.call(' foo@BAR.com')

      assert_event_logs(result1, size: 2)

      assert(result2.success?(:normalized_input))
      assert_equal({ input: 'foo@bar.com' }, result2.value)
      assert_kind_of(::Solid::Output, result2)
    ensure
      Solid::Result.config.feature.disable!(:and_then!)
    end
  end
end
