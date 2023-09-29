# frozen_string_literal: true

require 'test_helper'
require 'result'

class ResultTest < Minitest::Test
  test 'Result is defined' do
    assert defined?(Result)

    assert_same BCDD::Result, Result
  end
end
