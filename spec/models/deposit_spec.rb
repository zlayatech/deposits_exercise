require 'rails_helper'

RSpec.describe Deposit, type: :model do
  subject(:deposit) { FactoryBot.build :deposit }

  it 'is valid with valid attributes' do
    expect(deposit).to be_valid
  end

  it 'requires a tradeline' do
    deposit.tradeline = nil

    expect(deposit).not_to be_valid
    expect(deposit.errors[:tradeline]).to include('must exist')
  end

  it 'requires a deposit date' do
    deposit.deposit_date = nil

    expect(deposit).not_to be_valid
    expect(deposit.errors[:deposit_date]).to include("can't be blank")
  end

  it 'requires an amount' do
    deposit.amount = nil

    expect(deposit).not_to be_valid
    expect(deposit.errors[:amount]).to include("can't be blank")
  end

  it 'requires a positive amount' do
    [0, -10].each do |amount|
      deposit.amount = amount

      expect(deposit).not_to be_valid
      expect(deposit.errors[:amount]).to include('must be greater than 0')
    end
  end

  it 'enforces a positive amount at the database level' do
    deposit.save!

    expect { deposit.update_column(:amount, 0) }.to raise_error(ActiveRecord::StatementInvalid)
  end
end
