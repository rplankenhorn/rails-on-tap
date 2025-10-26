class Api::V1::TapsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_key

  # GET /api/v1/taps
  def index
    @taps = KegTap.all.includes(current_keg: :beverage, meter: [], flow_toggle: [], temperature_sensor: [])
    render json: @taps.map { |tap| tap_json(tap) }
  end

  # GET /api/v1/taps/:id
  def show
    @tap = KegTap.find(params[:id])
    render json: tap_json(@tap)
  end

  private

  def tap_json(tap)
    {
      id: tap.id,
      name: tap.name,
      position: tap.sort_order,
      keg: tap.current_keg ? {
        id: tap.current_keg.id,
        name: tap.current_keg.beverage&.name,
        beverage_id: tap.current_keg.beverage_id,
        status: tap.current_keg.status,
        started_at: tap.current_keg.start_time&.iso8601,
        ended_at: tap.current_keg.end_time&.iso8601,
        initial_volume: tap.current_keg.full_volume_ml,
        final_volume: tap.current_keg.served_volume_ml,
        beverage: tap.current_keg.beverage ? {
          id: tap.current_keg.beverage.id,
          name: tap.current_keg.beverage.name,
          style: tap.current_keg.beverage.style,
          beverage_type: tap.current_keg.beverage.beverage_type,
          abv_percent: tap.current_keg.beverage.abv_percent,
          beverage_producer: tap.current_keg.beverage.beverage_producer ? {
            id: tap.current_keg.beverage.beverage_producer.id,
            name: tap.current_keg.beverage.beverage_producer.name,
            country: tap.current_keg.beverage.beverage_producer.country,
            origin_state: tap.current_keg.beverage.beverage_producer.origin_state,
            origin_city: tap.current_keg.beverage.beverage_producer.origin_city
          } : nil
        } : nil
      } : nil,
      flow_meter: tap.meter ? {
        id: tap.meter.id,
        name: "Flow Meter ##{tap.meter.id}",
        port: tap.meter.port_name
      } : nil,
      flow_toggle: tap.flow_toggle ? {
        id: tap.flow_toggle.id,
        name: "Flow Toggle ##{tap.flow_toggle.id}",
        port: tap.flow_toggle.port_name
      } : nil,
      hardware_controller: nil,
      updated_at: tap.updated_at.iso8601
    }
  end

  def authenticate_api_key
    api_key = request.headers["X-API-Key"] || params[:api_key]

    unless api_key && ApiKey.find_by(key: api_key, active: true)
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
