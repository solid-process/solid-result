# frozen_string_literal: true

require 'bundler/inline'

$LOAD_PATH.unshift(__dir__)

require_relative 'config/boot'
require_relative 'config/initializers/solid_result'

require 'db/setup'

require 'lib/solid/result/rollback_on_failure'
require 'lib/single_event_logs_listener'
require 'lib/runtime_breaker'

require 'app/models/account'
require 'app/models/account/member'
require 'app/models/user'
require 'app/models/user/token'

require 'app/models/account/owner_creation'
require 'app/models/user/token/creation'
require 'app/models/user/creation'
