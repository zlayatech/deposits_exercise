require 'rails_helper'

RSpec.describe Tradeline, type: :model do
  let(:tradeline) { FactoryBot.create :tradeline }

  it 'has many deposits' do
    deposits = FactoryBot.create_list :deposit, 2, tradeline: tradeline

    expect(tradeline.deposits).to match_array(deposits)
  end

  it 'cannot be destroyed while it has deposits' do
    FactoryBot.create :deposit, tradeline: tradeline

    expect(tradeline.destroy).to be(false)
    expect(tradeline.errors[:base]).to include('Cannot delete record because dependent deposits exist')
  end
end
