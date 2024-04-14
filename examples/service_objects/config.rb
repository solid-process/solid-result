# frozen_string_literal: true

require 'bundler/inline'

$LOAD_PATH.unshift(__dir__)

require_relative 'config/boot'
require_relative 'config/initializers/solid_result'

require 'db/setup'

require 'app/models/account'
require 'app/models/account/member'
require 'app/models/user'
require 'app/models/user/token'

require 'app/services/application_service'
require 'app/services/account/owner_creation'
require 'app/services/user/token/creation'
require 'app/services/user/creation'
