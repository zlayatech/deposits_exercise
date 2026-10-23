require 'rails_helper'

RSpec.describe 'Deposits', type: :request do
  let(:tradeline) { FactoryBot.create :tradeline, amount: 1000 }

  describe 'GET /tradelines/:tradeline_id/deposits' do
    it 'lists the deposits for the tradeline ordered by date' do
      later = FactoryBot.create :deposit, tradeline: tradeline, deposit_date: Date.new(2030, 2, 1)
      earlier = FactoryBot.create :deposit, tradeline: tradeline, deposit_date: Date.new(2030, 1, 1)
      FactoryBot.create :deposit

      get "/tradelines/#{tradeline.id}/deposits"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.pluck('id')).to eq([earlier.id, later.id])
    end

    it 'responds with a 404 when the tradeline is not found' do
      get '/tradelines/1000/deposits'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /tradelines/:tradeline_id/deposits/:id' do
    let(:deposit) { FactoryBot.create :deposit, tradeline: tradeline, amount: 250.5, deposit_date: Date.new(2030, 1, 1) }

    it 'returns the deposit' do
      get "/tradelines/#{tradeline.id}/deposits/#{deposit.id}"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(
        'id' => deposit.id,
        'tradeline_id' => tradeline.id,
        'deposit_date' => '2030-01-01',
        'amount' => '250.5'
      )
    end

    it 'responds with a 404 when the deposit belongs to another tradeline' do
      other_deposit = FactoryBot.create :deposit

      get "/tradelines/#{tradeline.id}/deposits/#{other_deposit.id}"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /tradelines/:tradeline_id/deposits' do
    let(:params) { { deposit: { deposit_date: '2030-01-01', amount: '400.25' } } }

    it 'creates a deposit' do
      expect {
        post "/tradelines/#{tradeline.id}/deposits", params: params, as: :json
      }.to change(tradeline.deposits, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to include('deposit_date' => '2030-01-01', 'amount' => '400.25')
    end

    it 'allows a deposit that pays off the outstanding balance' do
      post "/tradelines/#{tradeline.id}/deposits", params: { deposit: { deposit_date: '2030-01-01', amount: 1000 } }, as: :json

      expect(response).to have_http_status(:created)
      expect(tradeline.outstanding_balance).to eq(0)
    end

    it 'rejects a deposit that exceeds the outstanding balance' do
      FactoryBot.create :deposit, tradeline: tradeline, amount: 700

      expect {
        post "/tradelines/#{tradeline.id}/deposits", params: params, as: :json
      }.not_to change(Deposit, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to eq(
        'errors' => { 'amount' => ['cannot exceed the outstanding balance of 300.0'] }
      )
    end

    it 'returns validation errors for invalid attributes' do
      post "/tradelines/#{tradeline.id}/deposits", params: { deposit: { deposit_date: '', amount: -5 } }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body['errors']).to include(
        'deposit_date' => ["can't be blank"],
        'amount' => ['must be greater than 0']
      )
    end

    it 'responds with a 400 when the deposit params are missing' do
      post "/tradelines/#{tradeline.id}/deposits", params: {}, as: :json

      expect(response).to have_http_status(:bad_request)
    end

    it 'responds with a 404 when the tradeline is not found' do
      post '/tradelines/1000/deposits', params: params, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
