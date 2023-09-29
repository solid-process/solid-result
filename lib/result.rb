# frozen_string_literal: true

require_relative 'bcdd/result'

class Result < BCDD::Result
end

class Result::Success < BCDD::Result::Success
end

class Result::Failure < BCDD::Result::Failure
end

module Result::Mixin
  include BCDD::Result::Mixin
end
