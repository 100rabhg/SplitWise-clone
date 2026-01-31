# frozen_string_literal: true

class Item < ExpenseItem
  validates :name, presence: true
end
