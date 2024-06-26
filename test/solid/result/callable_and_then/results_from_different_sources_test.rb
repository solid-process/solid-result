# frozen_string_literal: true

require 'test_helper'

class Solid::Result
  class CallableAndThenResultFromDifferentSourcesTest < Minitest::Test
    include SolidResultEventLogAssertions

    module NormalizeEmail
      extend Solid::Result.mixin

      def self.call(input)
        Solid::Result.event_logs(name: 'NormalizeEmail') do
          Given(input).and_then(:normalize)
        end
      end

      def self.normalize(input)
        input.is_a?(::String) or return Failure(:invalid_input, 'input must be a String')

        Success(:normalized_input, input.downcase.strip)
      end
    end

    class EmailValidation
      include Solid::Result.mixin

      def initialize(expected_pattern: /\A[^@\s]+@[^@\s]+\z/)
        @expected_pattern = expected_pattern
      end

      def call(input)
        Solid::Result.event_logs(name: 'EmailValidation') do
          Given(input).and_then(:validate)
        end
      end

      def validate(input)
        input.match?(@expected_pattern) ? Success(:valid_email, input) : Failure(:invalid_email, input)
      end
    end

    module NormalizeAndValidateEmail
      extend Solid::Result.mixin

      def self.call(email)
        Solid::Result.event_logs(name: 'NormalizeAndValidateEmail') do
          Given(email)
            .and_then!(NormalizeEmail)
            .and_then!(EmailValidation.new)
        end
      end
    end

    def setup
      Solid::Result.config.feature.enable!(:and_then!)
    end

    def teardown
      Solid::Result.config.feature.disable!(:and_then!)
    end

    test 'results from different sources' do
      result1 = NormalizeAndValidateEmail.call(nil)
      result2 = NormalizeAndValidateEmail.call('  ')
      result3 = NormalizeAndValidateEmail.call(" FOO@bAr.com  \n")

      assert(result1.failure?(:invalid_input))
      assert_equal('input must be a String', result1.value)

      assert(result2.failure?(:invalid_email))
      assert_equal('', result2.value)

      assert(result3.success?(:valid_email))
      assert_equal('foo@bar.com', result3.value)
    end

    test 'the event_logs tracking' do
      result1 = NormalizeAndValidateEmail.call(1)

      assert_event_logs(result1, size: 3)

      assert_equal([0, [[1, []]]], result1.event_logs[:metadata][:ids][:tree])

      root = { id: 0, name: 'NormalizeAndValidateEmail', desc: nil }

      source = -> { _1 == NormalizeAndValidateEmail }

      {
        root: root,
        parent: root,
        current: root,
        result: { kind: :success, type: :_given_, value: 1, source: source }
      }.then { assert_event_log_record(result1, 0, _1) }

      source = -> { _1 == NormalizeEmail }

      {
        root: root,
        parent: root,
        current: { id: 1, name: 'NormalizeEmail', desc: nil },
        result: { kind: :success, type: :_given_, value: 1, source: source }
      }.then { assert_event_log_record(result1, 1, _1) }

      {
        root: root,
        parent: root,
        current: { id: 1, name: 'NormalizeEmail', desc: nil },
        result: { kind: :failure, type: :invalid_input, value: 'input must be a String', source: source },
        and_then: { type: :method, arg: nil, method_name: :normalize }
      }.then { assert_event_log_record(result1, 2, _1) }

      # ---

      result2 = NormalizeAndValidateEmail.call(" FOO@bAr.com  \n")

      assert_event_logs(result2, size: 5)

      assert_equal([0, [[1, []], [2, []]]], result2.event_logs[:metadata][:ids][:tree])

      root = { id: 0, name: 'NormalizeAndValidateEmail', desc: nil }

      source = -> { _1 == NormalizeAndValidateEmail }

      {
        root: root,
        parent: root,
        current: root,
        result: { kind: :success, type: :_given_, value: " FOO@bAr.com  \n", source: source }
      }.then { assert_event_log_record(result2, 0, _1) }

      source = -> { _1 == NormalizeEmail }

      {
        root: root,
        parent: root,
        current: { id: 1, name: 'NormalizeEmail', desc: nil },
        result: { kind: :success, type: :_given_, value: " FOO@bAr.com  \n", source: source }
      }.then { assert_event_log_record(result2, 1, _1) }

      {
        root: root,
        parent: root,
        current: { id: 1, name: 'NormalizeEmail', desc: nil },
        result: { kind: :success, type: :normalized_input, value: 'foo@bar.com', source: source },
        and_then: { type: :method, arg: nil, method_name: :normalize }
      }.then { assert_event_log_record(result2, 2, _1) }

      {
        root: root,
        parent: root,
        current: { id: 2, name: 'EmailValidation', desc: nil },
        result: { kind: :success, type: :_given_, value: 'foo@bar.com', source: EmailValidation }
      }.then { assert_event_log_record(result2, 3, _1) }

      {
        root: root,
        parent: root,
        current: { id: 2, name: 'EmailValidation', desc: nil },
        result: { kind: :success, type: :valid_email, value: 'foo@bar.com', source: EmailValidation },
        and_then: { type: :method, arg: nil, method_name: :validate }
      }.then { assert_event_log_record(result2, 4, _1) }
    end
  end
end
