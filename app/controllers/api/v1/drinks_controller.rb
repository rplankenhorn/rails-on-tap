class Api::V1::DrinksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_key

  def index
    @drinks = Drink.includes(:user, keg: :beverage)
                   .order(time: :desc)
                   .limit(params[:limit] || 50)
    render json: @drinks, include: [ :user, keg: :beverage ]
  end

  def show
    @drink = Drink.find(params[:id])
    render json: @drink, include: [ :user, { keg: :beverage }, :drinking_session ]
  end

  def create
    # Record a drink pour from hardware
    # Expected params:
    #   tap_name or meter_name: string
    #   ticks: integer
    #   volume_ml: float (optional, calculated from ticks if not provided)
    #   username: string (optional)
    #   shout: string (optional)
    #   duration: integer (optional)
    #   spilled: boolean (optional)

    tap_name = params[:tap_name] || params[:meter_name]

    begin
      drink = Drink.record_drink(
        tap_or_meter_name: tap_name,
        ticks: params[:ticks].to_i,
        volume_ml: params[:volume_ml]&.to_f,
        username: params[:username],
        pour_time: params[:pour_time] ? Time.parse(params[:pour_time]) : nil,
        duration: params[:duration]&.to_i || 0,
        shout: params[:shout] || "",
        spilled: params[:spilled] == "true"
      )

      if drink
        render json: drink, include: [ :user, keg: :beverage ], status: :created
      else
        render json: { message: "Drink recorded as spill" }, status: :ok
      end
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  private

  def authenticate_api_key
    api_key = request.headers["X-API-Key"] || params[:api_key]

    unless api_key && ApiKey.find_by(key: api_key, active: true)
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
