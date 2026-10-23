class Deposit < ApplicationRecord
  belongs_to :tradeline

  validates :deposit_date, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :amount_within_outstanding_balance, on: :create

  private

  def amount_within_outstanding_balance
    return if tradeline.nil? || amount.nil?

    balance = tradeline.outstanding_balance
    errors.add(:amount, "cannot exceed the outstanding balance of #{balance}") if amount > balance
  end
end
