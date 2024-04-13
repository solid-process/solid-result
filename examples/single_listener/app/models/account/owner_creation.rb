# frozen_string_literal: true

class Account
  class OwnerCreation
    include Solid::Output.mixin
    include Solid::Result::RollbackOnFailure

    def call(**input)
      Solid::Result.event_logs(name: self.class.name) do
        Given(input)
          .and_then(:normalize_input)
          .and_then(:validate_input)
          .then { |result|
            rollback_on_failure {
              result
                .and_then(:create_owner)
                .and_then(:create_account)
                .and_then(:link_owner_to_account)
            }
          }.and_expose(:account_owner_created, %i[user account])
      end
    end

    private

    def normalize_input(**options)
      uuid = String(options.fetch(:uuid) { ::SecureRandom.uuid }).strip.downcase

      Continue(uuid:)
    end

    def validate_input(uuid:, owner:)
      err = ::Hash.new { |hash, key| hash[key] = [] }

      err[:uuid] << 'must be an UUID' unless uuid.match?(/\A[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}\z/i)
      err[:owner] << 'must be a Hash' unless owner.is_a?(::Hash)

      err.empty? ? Continue() : Failure(:invalid_input, **err)
    end

    def create_owner(owner:, **)
      ::User::Creation.new.call(**owner).handle do |on|
        on.success { |output| Continue(user: { record: output[:user], token: output[:token] }) }
        on.failure { |output| Failure(:invalid_owner, **output) }
      end
    end

    def create_account(uuid:, **)
      ::RuntimeBreaker.try_to_interrupt(env: 'BREAK_ACCOUNT_CREATION')

      account = ::Account.create(uuid:)

      account.persisted? ? Continue(account:) : Failure(:invalid_record, **account.errors.messages)
    end

    def link_owner_to_account(account:, user:, **)
      Member.create!(account:, user: user.fetch(:record), role: :owner)

      Continue()
    end
  end
end
