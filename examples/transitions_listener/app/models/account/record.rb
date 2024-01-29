# frozen_string_literal: true

class Account::Record < ActiveRecord::Base
  self.table_name = 'accounts'

  has_many :memberships, inverse_of: :account, dependent: :destroy, class_name: '::Account::Member::Record'
  has_many :users, through: :memberships, inverse_of: :accounts, class_name: '::User::Record'

  where_ownership = -> { where(account_members: {role: :owner}) }

  has_one :ownership, where_ownership, dependent: nil, inverse_of: :account, class_name: '::Account::Member::Record'
  has_one :owner, through: :ownership, source: :user, class_name: '::User::Record'
end
