# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::VersionTest < Minitest::Test
  test 'should has a version number' do
    refute_nil ::BCDD::Result::VERSION
  end
end
