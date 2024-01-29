# frozen_string_literal: true

require 'bundler/inline'

$LOAD_PATH.unshift(__dir__)

require_relative 'config/boot'
require_relative 'config/initializers/bcdd'

require 'db/setup'

require 'lib/bcdd/result/rollback_on_failure'
require 'lib/my_bcdd_result_transitions_listener'
require 'lib/runtime_breaker'

module Account
  require 'app/models/account/record'
  require 'app/models/account/owner_creation'
  require 'app/models/account/member/record'
end

module User
  require 'app/models/user/record'
  require 'app/models/user/creation'

  require 'app/models/user/token/record'
  require 'app/models/user/token/creation'
end
