class DepositsController < ApplicationController
  before_action :set_tradeline

  def index
    @deposits = @tradeline.deposits.order(:deposit_date)
  end

  def show
    @deposit = @tradeline.deposits.find(params[:id])
  end

  def create
    @deposit = @tradeline.deposits.build(deposit_params)

    # Lock the tradeline so concurrent deposits can't both pass the balance check.
    if @tradeline.with_lock { @deposit.save }
      render :show, status: :created
    else
      render json: { errors: @deposit.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_tradeline
    @tradeline = Tradeline.find(params[:tradeline_id])
  end

  def deposit_params
    params.require(:deposit).permit(:deposit_date, :amount)
  end
end
