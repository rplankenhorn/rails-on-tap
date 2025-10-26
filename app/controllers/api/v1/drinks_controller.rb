class Api::V1::DrinksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_key

  def index
    @drinks = Drink.includes(:user, keg: :beverage)
                   .order(time: :desc)
                   .limit(params[:limit] || 50)
    render json: @drinks.map { |drink| drink_json(drink) }
  end

  def show
    @drink = Drink.find(params[:id])
    render json: drink_json(@drink)
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

  def drink_json(drink)
    {
      id: drink.id,
      ticks: drink.ticks,
      volume_ml: drink.volume_ml,
      time: drink.time.iso8601,
      duration: drink.duration,
      shout: drink.shout,
      user: {
        id: drink.user.id,
        username: drink.user.username,
        display_name: drink.user.display_name,
        email: drink.user.email
      },
      keg: {
        id: drink.keg.id,
        name: drink.keg.beverage&.name,
        beverage_id: drink.keg.beverage_id,
        status: drink.keg.status,
        started_at: drink.keg.start_time&.iso8601,
        ended_at: drink.keg.end_time&.iso8601,
        initial_volume: drink.keg.full_volume_ml,
        final_volume: drink.keg.served_volume_ml,
        beverage: drink.keg.beverage ? {
          id: drink.keg.beverage.id,
          name: drink.keg.beverage.name,
          style: drink.keg.beverage.style,
          beverage_type: drink.keg.beverage.beverage_type,
          abv_percent: drink.keg.beverage.abv_percent,
          beverage_producer: drink.keg.beverage.beverage_producer ? {
            id: drink.keg.beverage.beverage_producer.id,
            name: drink.keg.beverage.beverage_producer.name,
            country: drink.keg.beverage.beverage_producer.country,
            origin_state: drink.keg.beverage.beverage_producer.origin_state,
            origin_city: drink.keg.beverage.beverage_producer.origin_city
          } : nil
        } : nil
      },
      drinking_session: drink.drinking_session ? {
        id: drink.drinking_session.id,
        start_time: drink.drinking_session.start_time&.iso8601,
        end_time: drink.drinking_session.end_time&.iso8601
      } : nil
    }
  end

  def authenticate_api_key
    api_key = request.headers["X-API-Key"] || params[:api_key]

    unless api_key && ApiKey.find_by(key: api_key, active: true)
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
