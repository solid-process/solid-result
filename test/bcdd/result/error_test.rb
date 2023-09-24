# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::ErrorTest < Minitest::Test
  test '::Error' do
    assert BCDD::Result::Error < StandardError
  end

  test '::Error::NotImplemented' do
    assert BCDD::Result::Error::NotImplemented < BCDD::Result::Error
  end

  test '::Error::MissingTypeArgument' do
    assert BCDD::Result::Error::MissingTypeArgument < BCDD::Result::Error

    assert_equal 'a type must be defined', BCDD::Result::Error::MissingTypeArgument.new.message
  end

  test '::Error::UnexpectedBlockResult' do
    assert BCDD::Result::Error::UnexpectedBlockResult < BCDD::Result::Error

    assert_equal(
      'block must return a BCDD::Result::Success or BCDD::Result::Failure',
      BCDD::Result::Error::UnexpectedBlockResult.new.message
    )
  end
end
