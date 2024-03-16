# frozen_string_literal: true

class User::Token
  class Creation
    include BCDD::Context.mixin

    def call(**input)
      BCDD::Result.event_logs(name: self.class.name) do
        Given(input)
          .and_then(:normalize_input)
          .and_then(:validate_input)
          .and_then(:validate_token_existence)
          .and_then(:create_token)
          .and_expose(:token_created, %i[token])
      end
    end

    private

    def normalize_input(**options)
      Continue(executed_at: options.fetch(:executed_at) { ::Time.current })
    end

    def validate_input(user:, executed_at:)
      err = ::Hash.new { |hash, key| hash[key] = [] }

      err[:user] << 'must be a User' unless user.is_a?(::User)
      err[:user] << 'must be persisted' unless user.try(:persisted?)
      err[:executed_at] << 'must be a time' unless executed_at.is_a?(::Time)

      err.empty? ? Continue() : Failure(:invalid_user, **err)
    end

    def validate_token_existence(user:, **)
      user.token.nil? ? Continue() : Failure(:token_already_exists)
    end

    def create_token(user:, executed_at:, **)
      ::RuntimeBreaker.try_to_interrupt(env: 'BREAK_USER_TOKEN_CREATION')

      token = user.create_token(
        access_token: ::SecureRandom.hex(24),
        refresh_token: ::SecureRandom.hex(24),
        access_token_expires_at: executed_at + 15.days,
        refresh_token_expires_at: executed_at + 30.days
      )

      token.persisted? ? Continue(token:) : Failure(:token_creation_failed, **token.errors.messages)
    end
  end
end
