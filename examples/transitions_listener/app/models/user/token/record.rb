# frozen_string_literal: true

module User::Token
  class Record < ActiveRecord::Base
    self.table_name = 'user_tokens'

    belongs_to :user, class_name: 'User::Record', inverse_of: :token
  end
end
