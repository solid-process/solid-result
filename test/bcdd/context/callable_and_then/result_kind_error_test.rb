# frozen_string_literal: true

require 'test_helper'

module BCDD
  class Context::CallableAndThenResultKindErrorTest < Minitest::Test
    module NormalizeEmail
      extend Context.mixin

      def self.call(input:)
        BCDD::Result.event_logs(name: 'NormalizeEmail') do
          Given(input: input).and_then(:normalize)
        end
      end

      def self.normalize(input:)
        input.is_a?(::String) or return ::BCDD::Result::Failure(:invalid_input, message: 'input must be a String')

        ::BCDD::Result::Success(:normalized_input, input: input.downcase.strip)
      end
    end

    module EmailNormalization
      extend Context.mixin

      def self.call(input)
        BCDD::Result.event_logs(name: 'EmailNormalization') do
          Given(input: input)
            .and_then!(NormalizeEmail)
        end
      end
    end

    test 'results from different sources' do
      BCDD::Result.config.feature.enable!(:and_then!)

      error = assert_raises(BCDD::Result::Error::UnexpectedOutcome) { EmailNormalization.call(nil) }

      expected_message = [
        'Unexpected outcome: #<BCDD::Result::Failure type=:invalid_input value={:message=>"input must be a String"}>.',
        'The method must return this object wrapped by BCDD::Context::Success or BCDD::Context::Failure'
      ].join(' ')

      assert_equal(expected_message, error.message)
    ensure
      BCDD::Result.config.feature.disable!(:and_then!)
    end
  end
end
