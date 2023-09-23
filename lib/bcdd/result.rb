# frozen_string_literal: true

require_relative 'result/version'

module BCDD::Result
  require_relative 'result/error'
  require_relative 'result/base'
  require_relative 'result/failure'
  require_relative 'result/success'

  private_constant :Base
end
