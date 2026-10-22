class Tradeline < ApplicationRecord
  has_many :deposits, dependent: :restrict_with_error

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def outstanding_balance
    amount - deposits.sum(&:amount)
  end
end
