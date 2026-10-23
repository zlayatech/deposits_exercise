class TradelinesController < ApplicationController
  def index
    @tradelines = Tradeline.all
  end

  def show
    @tradeline = Tradeline.find(params[:id])
  end
end
