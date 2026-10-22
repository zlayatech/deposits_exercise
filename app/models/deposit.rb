class Deposit < ApplicationRecord
  belongs_to :tradeline

  validates :deposit_date, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
end
