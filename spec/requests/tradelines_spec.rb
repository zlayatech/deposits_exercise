require 'rails_helper'

RSpec.describe 'Tradelines', type: :request do
  let(:tradeline) { FactoryBot.create :tradeline, name: 'Car Loan', amount: 1000 }

  before do
    FactoryBot.create :deposit, tradeline: tradeline, amount: 150.25
    FactoryBot.create :deposit, tradeline: tradeline, amount: 49.75
  end

  describe 'GET /tradelines' do
    it 'lists tradelines with their outstanding balance' do
      other_tradeline = FactoryBot.create :tradeline, amount: 500

      get '/tradelines'

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to contain_exactly(
        a_hash_including('id' => tradeline.id, 'amount' => '1000.0', 'outstanding_balance' => '800.0'),
        a_hash_including('id' => other_tradeline.id, 'amount' => '500.0', 'outstanding_balance' => '500.0')
      )
    end
  end

  describe 'GET /tradelines/:id' do
    it 'returns the tradeline with its outstanding balance' do
      get "/tradelines/#{tradeline.id}"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(
        'id' => tradeline.id,
        'name' => 'Car Loan',
        'amount' => '1000.0',
        'outstanding_balance' => '800.0'
      )
    end

    it 'responds with a 404 when the tradeline is not found' do
      get '/tradelines/1000'

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq('error' => 'not_found')
    end
  end
end
