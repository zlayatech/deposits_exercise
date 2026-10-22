require 'rails_helper'

RSpec.describe Tradeline, type: :model do
  let(:tradeline) { FactoryBot.create :tradeline, amount: 1000 }

  it 'has many deposits' do
    deposits = FactoryBot.create_list :deposit, 2, tradeline: tradeline

    expect(tradeline.deposits).to match_array(deposits)
  end

  it 'cannot be destroyed while it has deposits' do
    FactoryBot.create :deposit, tradeline: tradeline

    expect(tradeline.destroy).to be(false)
    expect(tradeline.errors[:base]).to include('Cannot delete record because dependent deposits exist')
  end

  describe 'validations' do
    it 'requires an amount' do
      tradeline.amount = nil

      expect(tradeline).not_to be_valid
      expect(tradeline.errors[:amount]).to include("can't be blank")
    end

    it 'rejects a negative amount' do
      tradeline.amount = -1

      expect(tradeline).not_to be_valid
      expect(tradeline.errors[:amount]).to include('must be greater than or equal to 0')
    end
  end

  describe '#outstanding_balance' do
    it 'equals the amount when there are no deposits' do
      expect(tradeline.outstanding_balance).to eq(1000)
    end

    it 'subtracts all deposit amounts' do
      FactoryBot.create :deposit, tradeline: tradeline, amount: 250.25
      FactoryBot.create :deposit, tradeline: tradeline, amount: 100.10

      expect(tradeline.outstanding_balance).to eq(BigDecimal('649.65'))
    end

    it 'ignores unsaved deposits' do
      tradeline.deposits.build(amount: 100)

      expect(tradeline.outstanding_balance).to eq(1000)
    end

    it 'ignores deposits on other tradelines' do
      FactoryBot.create :deposit, amount: 300

      expect(tradeline.outstanding_balance).to eq(1000)
    end
  end
end
