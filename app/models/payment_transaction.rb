# frozen_string_literal: true

class PaymentTransaction < Transaction
  belongs_to :friendship

  # Trigger balance recalculation when payment is made
  after_commit :trigger_balance_recalculation, on: %i[create update destroy]

  private

  def trigger_balance_recalculation
    RecalculateFriendshipBalanceJob.perform_later(friendship_id) if friendship_id.present?
  end
end
