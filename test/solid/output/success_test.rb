# frozen_string_literal: true

require 'test_helper'

module Solid
  class OutputSuccessTest < Minitest::Test
    test 'is a Solid::Output' do
      assert Output::Success < Solid::Output
    end

    test 'is a Solid::Success' do
      assert Output::Success < Solid::Success
    end

    test '#inspect' do
      result = Output::Success(:ok, number: 1)

      assert_equal(
        '#<Solid::Output::Success type=:ok value={:number=>1}>',
        result.inspect
      )
    end

    test '#[]' do
      result1 = Output::Success(:ok)
      result2 = Output::Success(:ok, a: 1, b: 2)

      assert_nil result1[:a]
      assert_nil result1[:b]

      assert_equal 1, result2[:a]
      assert_equal 2, result2[:b]
    end

    # rubocop:disable Style/SingleArgumentDig
    test '#dig' do
      result1 = Output::Success(:ok)
      result2 = Output::Success(:ok, a: { b: 1 })

      assert_nil result1.dig(:a, :b)
      assert_nil result2.dig(:a, :c)

      assert_equal({ b: 1 }, result2.dig(:a))
      assert_equal 1, result2.dig(:a, :b)
    end
    # rubocop:enable Style/SingleArgumentDig

    test '#fetch' do
      result1 = Output::Success(:ok)
      result2 = Output::Success(:ok, a: 1, b: 2)

      assert_raises(KeyError) { result1.fetch(:a) }
      assert_raises(KeyError) { result1.fetch(:b) }

      assert_equal 1, result2.fetch(:a)
      assert_equal 2, result2.fetch(:b)

      # ---

      assert_equal 3, result1.fetch(:a, 3)
      assert_equal 4, result1.fetch(:b, 4)

      assert_equal 1, result2.fetch(:a, 3)
      assert_equal 2, result2.fetch(:b, 4)

      # ---

      # rubocop:disable Style/RedundantFetchBlock
      assert_equal(5, result1.fetch(:a) { 5 })
      assert_equal(6, result1.fetch(:b) { 6 })

      assert_equal(1, result2.fetch(:a) { 7 })
      assert_equal(2, result2.fetch(:b) { 8 })
      # rubocop:enable Style/RedundantFetchBlock
    end

    test '#slice' do
      result1 = Output::Success(:ok)
      result2 = Output::Success(:ok, a: 1, b: 2)

      assert_equal({}, result1.slice(:a, :b))
      assert_equal({ a: 1, b: 2 }, result2.slice(:a, :b))
    end

    test '#values_at' do
      result1 = Output::Success(:ok)
      result2 = Output::Success(:ok, a: 1, b: 2)

      assert_equal [nil, nil], result1.values_at(:a, :b)
      assert_equal [1, 2], result2.values_at(:a, :b)
    end

    test '#fetch_values' do
      result1 = Output::Success(:ok)
      result2 = Output::Success(:ok, a: 1, b: 2)

      assert_raises(KeyError) do
        result1.fetch_values(:a, :b)
      end

      assert_equal [1, 2], result2.fetch_values(:a, :b)

      # ---

      values1 = result1.fetch_values(:a, :b, :c, :d) { |key| key.to_s.upcase }
      values2 = result2.fetch_values(:a, :b, :c, :d) { |key| key.to_s.upcase }

      assert_equal %w[A B C D], values1

      assert_equal [1, 2, 'C', 'D'], values2
    end
  end
end
