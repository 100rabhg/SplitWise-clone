# frozen_string_literal: true

class ExpenseTransaction < Transaction
  include AmountSumValidatable

  has_many :expense_items, foreign_key: :transaction_id, inverse_of: :expense_transaction, dependent: :destroy
  accepts_nested_attributes_for :expense_items, allow_destroy: true

  validates_amount_equals_sum_of :expense_items

  # Capture friendships before data changes
  before_update :capture_friendships_before_change

  def destroy
    capture_friendships_before_change
    super
  end

  # Trigger recalculation after transaction completes
  after_commit :trigger_balance_recalculations, on: %i[create update destroy]

  private

  def capture_friendships_before_change
    @friendship_ids_before = fetch_friendship_ids
  end

  def trigger_balance_recalculations
    # CREATE:
    # Only the "after" state exists, so fetch current friendships
    #
    # UPDATE:
    # Users may be added or removed. Merge friendships from
    # before + after state to ensure no affected friendship is missed.
    #
    # DESTROY:
    # After destroy, associations are gone, so rely only on
    # friendships captured before deletion.
    friendship_ids = if transaction_include_any_action?([:create])
                       fetch_friendship_ids
                     elsif transaction_include_any_action?([:destroy])
                       @friendship_ids_before.to_a
                     else # update
                       (@friendship_ids_before.to_a + fetch_friendship_ids).uniq
                     end

    friendship_ids.each do |friendship_id|
      RecalculateFriendshipBalanceJob.perform_later(friendship_id)
    end
  end

  def fetch_friendship_ids
    ItemSplit
      .joins(:expense_item)
      .where(expense_items: { transaction_id: id })
      .distinct
      .pluck(:friendship_id)
  end
end
