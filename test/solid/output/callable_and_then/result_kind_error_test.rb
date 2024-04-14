# frozen_string_literal: true

require 'test_helper'

module Solid
  class Output::CallableAndThenResultKindErrorTest < Minitest::Test
    module NormalizeEmail
      extend Output.mixin

      def self.call(input:)
        Solid::Result.event_logs(name: 'NormalizeEmail') do
          Given(input: input).and_then(:normalize)
        end
      end

      def self.normalize(input:)
        input.is_a?(::String) or return ::Solid::Result::Failure(:invalid_input, message: 'input must be a String')

        ::Solid::Result::Success(:normalized_input, input: input.downcase.strip)
      end
    end

    module EmailNormalization
      extend Output.mixin

      def self.call(input)
        Solid::Result.event_logs(name: 'EmailNormalization') do
          Given(input: input)
            .and_then!(NormalizeEmail)
        end
      end
    end

    test 'results from different sources' do
      Solid::Result.config.feature.enable!(:and_then!)

      error = assert_raises(Solid::Result::Error::UnexpectedOutcome) { EmailNormalization.call(nil) }

      expected_message = [
        'Unexpected outcome: #<Solid::Result::Failure type=:invalid_input value={:message=>"input must be a String"}>.',
        'The method must return this object wrapped by Solid::Output::Success or Solid::Output::Failure'
      ].join(' ')

      assert_equal(expected_message, error.message)
    ensure
      Solid::Result.config.feature.disable!(:and_then!)
    end
  end
end
