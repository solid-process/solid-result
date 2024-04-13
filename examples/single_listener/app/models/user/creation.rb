# frozen_string_literal: true

class User
  class Creation
    include Solid::Output.mixin
    include Solid::Result::RollbackOnFailure

    def call(**input)
      Solid::Result.event_logs(name: self.class.name) do
        Given(input)
          .and_then(:normalize_input)
          .and_then(:validate_input)
          .and_then(:validate_email_uniqueness)
          .then { |result|
            rollback_on_failure {
              result
                .and_then(:create_user)
                .and_then(:create_user_token)
            }
          }
          .and_expose(:user_created, %i[user token])
      end
    end

    private

    def normalize_input(name:, email:, **options)
      name = String(name).strip.gsub(/\s+/, ' ')
      email = String(email).strip.downcase

      uuid = String(options.fetch(:uuid) { ::SecureRandom.uuid }).strip.downcase

      Continue(uuid:, name:, email:)
    end

    def validate_input(uuid:, name:, email:, password:, password_confirmation:)
      err = ::Hash.new { |hash, key| hash[key] = [] }

      err[:uuid] << 'must be an UUID' unless uuid.match?(/\A[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}\z/i)
      err[:name] << 'must be present' if name.blank?
      err[:email] << 'must be email' unless email.match?(::URI::MailTo::EMAIL_REGEXP)
      err[:password] << 'must be present' if password.blank?
      err[:password_confirmation] << 'must be present' if password_confirmation.blank?

      err.empty? ? Continue() : Failure(:invalid_input, **err)
    end

    def validate_email_uniqueness(email:, **)
      ::User.exists?(email:) ? Failure(:email_already_taken) : Continue()
    end

    def create_user(uuid:, name:, email:, password:, password_confirmation:)
      ::RuntimeBreaker.try_to_interrupt(env: 'BREAK_USER_CREATION')

      user = ::User.create(uuid:, name:, email:, password:, password_confirmation:)

      user.persisted? ? Continue(user:) : Failure(:invalid_record, **user.errors.messages)
    end

    def create_user_token(user:, **)
      Token::Creation.new.call(user: user).handle do |on|
        on.success { |output| Continue(token: output[:token]) }
        on.failure { raise 'Token creation failed' }
      end
    end
  end
end
