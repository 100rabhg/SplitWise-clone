# frozen_string_literal: true

module AmountSumValidatable
  extend ActiveSupport::Concern

  included do
    class_attribute :_amount_sum_validations, default: []
  end

  class_methods do
    def validates_amount_equals_sum_of(association_name, amount_attr = nil, **opts)
      parent_amount_attr = opts[:parent_amount_attr] || amount_attr || :amount

      child_amount_attr = opts[:child_amount_attr] || amount_attr || :amount

      self._amount_sum_validations += [{
        association: association_name,
        parent_amount_attr: parent_amount_attr,
        child_amount_attr: child_amount_attr
      }]

      validate :_validate_amount_sum_associations
    end
  end

  private

  def _validate_amount_sum_associations
    self.class._amount_sum_validations.each do |cfg|
      validate_single_amount_sum(cfg)
    end
  end

  def validate_single_amount_sum(cfg)
    assoc       = cfg[:association]
    parent_attr = cfg[:parent_amount_attr]

    unless respond_to?(assoc)
      errors.add(:base, "Missing association #{assoc}")
      return
    end

    parent_value = BigDecimal(send(parent_attr).to_s.presence || '0')
    expected     = expected_amount_sum(cfg)

    return if parent_value == expected

    errors.add(parent_attr, "must equal sum of #{assoc}.#{cfg[:child_amount_attr]} (#{expected})")
  end

  def expected_amount_sum(cfg)
    assoc      = cfg[:association]
    child_attr = cfg[:child_amount_attr]

    send(assoc).to_a.reject(&:marked_for_destruction?).sum do |record|
      val = record.respond_to?(child_attr) ? record.send(child_attr) : 0
      BigDecimal(val.to_s)
    end
  end
end
