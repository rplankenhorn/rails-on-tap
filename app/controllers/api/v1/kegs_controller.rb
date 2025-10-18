class Api::V1::KegsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_key

  def index
    status_filter = params[:status]
    @kegs = Keg.includes(beverage: :beverage_producer)

    if status_filter.present?
      @kegs = @kegs.where(status: status_filter)
    end

    @kegs = @kegs.order(start_time: :desc).limit(params[:limit] || 50)

    render json: @kegs.map { |keg|
      {
        id: keg.id,
        beverage: keg.beverage.full_name,
        keg_type: keg.keg_type,
        status: keg.status,
        full_volume_ml: keg.full_volume_ml,
        served_volume_ml: keg.served_volume_ml,
        remaining_volume_ml: keg.remaining_volume_ml,
        percent_full: keg.percent_full,
        start_time: keg.start_time,
        end_time: keg.end_time
      }
    }
  end

  def show
    @keg = Keg.find(params[:id])
    render json: {
      id: @keg.id,
      beverage: @keg.beverage.full_name,
      keg_type: @keg.keg_type,
      status: @keg.status,
      full_volume_ml: @keg.full_volume_ml,
      served_volume_ml: @keg.served_volume_ml,
      remaining_volume_ml: @keg.remaining_volume_ml,
      percent_full: @keg.percent_full,
      start_time: @keg.start_time,
      end_time: @keg.end_time,
      description: @keg.description,
      tap: @keg.current_tap&.name
    }
  end

  private

  def authenticate_api_key
    api_key = request.headers["X-API-Key"] || params[:api_key]

    unless api_key && ApiKey.find_by(key: api_key, active: true)
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
