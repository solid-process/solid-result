# frozen_string_literal: true

require 'bundler/inline'

$LOAD_PATH.unshift(__dir__)

require_relative 'config/boot'
require_relative 'config/initializers/bcdd'

require 'db/setup'

require 'lib/bcdd/result/rollback_on_failure'
require 'lib/bcdd/result/event_logs_record'
require 'lib/runtime_breaker'

module EventLogsListener
  require 'lib/event_logs_listener/stdout'
end

require 'app/models/account'
require 'app/models/account/member'
require 'app/models/user'
require 'app/models/user/token'

require 'app/models/account/owner_creation'
require 'app/models/user/token/creation'
require 'app/models/user/creation'
