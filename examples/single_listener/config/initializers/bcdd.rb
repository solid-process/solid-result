# frozen_string_literal: true

BCDD::Result.config.then do |config|
  config.addon.enable!(:continue)

  config.constant_alias.enable!('BCDD::Context')

  config.pattern_matching.disable!(:nil_as_valid_value_checking)

  # config.feature.disable!(:expectations) if Rails.env.production?
end
