# frozen_string_literal: true

require 'set'

module Solid
  require_relative 'success'
  require_relative 'failure'

  class Result
    require_relative 'result/version'
    require_relative 'result/error'
    require_relative 'result/ignored_types'
    require_relative 'result/event_logs'
    require_relative 'result/callable_and_then'
    require_relative 'result/data'
    require_relative 'result/handler'
    require_relative 'result/failure'
    require_relative 'result/success'
    require_relative 'result/mixin'
    require_relative 'result/contract'
    require_relative 'result/expectations'
    require_relative 'result/config'
    require_relative 'result/_self'

    require_relative 'output'
  end
end
