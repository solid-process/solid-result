# frozen_string_literal: true

require 'test_helper'

module Solid
  class OutputFailureTest < Minitest::Test
    test 'is a Solid::Output' do
      assert Output::Failure < Solid::Output
    end

    test 'is a Solid::Failure' do
      assert Output::Failure < Solid::Failure
    end

    test '#inspect' do
      result = Output::Failure(:err, number: 0)

      assert_equal(
        '#<Solid::Output::Failure type=:err value={:number=>0}>',
        result.inspect
      )
    end
  end
end
