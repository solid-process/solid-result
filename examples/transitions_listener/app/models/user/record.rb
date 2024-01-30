# frozen_string_literal: true

class User::Record < ActiveRecord::Base
  self.table_name = 'users'

  has_secure_password

  has_many :memberships, inverse_of: :user, dependent: :destroy, class_name: '::Account::Member::Record'
  has_many :accounts, through: :memberships, inverse_of: :users, class_name: '::Account::Record'

  where_ownership = -> { where(account_members: { role: :owner }) }

  has_one :ownership, where_ownership, inverse_of: :user, class_name: '::Account::Member::Record'
  has_one :account, through: :ownership, inverse_of: :owner, class_name: '::Account::Record'

  has_one :token, inverse_of: :user, dependent: :destroy, class_name: '::User::Token::Record'
end
