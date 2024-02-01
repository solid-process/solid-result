# frozen_string_literal: true

module BCDD::Result::RollbackOnFailure
  def rollback_on_failure(model: ::ActiveRecord::Base)
    result = nil

    model.transaction do
      result = yield

      raise ::ActiveRecord::Rollback if result.failure?
    end

    result
  end
end
