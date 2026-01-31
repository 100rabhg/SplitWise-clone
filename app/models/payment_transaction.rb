# frozen_string_literal: true

class PaymentTransaction < Transaction
  belongs_to :friendship
end
