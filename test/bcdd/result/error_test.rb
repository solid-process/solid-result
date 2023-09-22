# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::ErrorTest < Minitest::Test
  test '::Error' do
    assert BCDD::Result::Error < StandardError
  end

  test '::Error::NotImplemented' do
    assert BCDD::Result::Error::NotImplemented < BCDD::Result::Error
  end
end
