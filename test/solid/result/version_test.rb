# frozen_string_literal: true

require 'test_helper'

class Solid::Result::VersionTest < Minitest::Test
  test 'should have a version number' do
    refute_nil ::Solid::Result::VERSION
  end
end
