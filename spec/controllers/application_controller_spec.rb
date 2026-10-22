require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      raise ActiveRecord::RecordNotFound
    end

    def create
      params.require(:deposit)
      head :ok
    end
  end

  it 'responds with a 404 when a record is not found' do
    get :index

    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body).to eq('error' => 'not_found')
  end

  it 'responds with a 400 when a required param is missing' do
    post :create

    expect(response).to have_http_status(:bad_request)
    expect(response.parsed_body['error']).to include('param is missing or the value is empty: deposit')
  end
end
