# frozen_string_literal: true

require 'test_helper'

module Solid
  class OutputTest < Minitest::Test
    test 'is a Solid::Result' do
      assert Output < Solid::Result
    end

    test '#initialize value validation' do
      err = assert_raises(ArgumentError) { Output.new(type: :ok, value: nil) }

      assert_equal 'value must be a Hash', err.message
    end

    test '::Success()' do
      result = Output::Success(:ok)

      assert_equal(:ok, result.type)
      assert_equal({}, result.value)

      # ---

      result = Output::Success(:yes, number: 1)

      assert_equal(:yes, result.type)
      assert_equal({ number: 1 }, result.value)

      # ---

      err = assert_raises(ArgumentError) { Output::Success(:ok, nil) }

      assert_equal 'wrong number of arguments (given 2, expected 1)', err.message
    end

    test '::Failure()' do
      result = Output::Failure(:no)

      assert_equal(:no, result.type)
      assert_equal({}, result.value)

      # ---

      result = Output::Failure(:err, number: 0)

      assert_equal(:err, result.type)
      assert_equal({ number: 0 }, result.value)

      # ---

      err = assert_raises(ArgumentError) { Output::Failure(:ok, nil) }

      assert_equal 'wrong number of arguments (given 2, expected 1)', err.message
    end
  end
end
