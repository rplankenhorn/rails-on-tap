class Api::V1::TapsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_key

  # GET /api/v1/taps
  def index
    @taps = Tap.all.includes(:keg, :flow_meter, :flow_toggle, :hardware_controller)
    render json: @taps.map { |tap| tap_json(tap) }
  end

  # GET /api/v1/taps/:id
  def show
    @tap = Tap.find(params[:id])
    render json: tap_json(@tap)
  end

  private

  def tap_json(tap)
    {
      id: tap.id,
      name: tap.name,
      position: tap.position,
      keg: tap.keg ? {
        id: tap.keg.id,
        name: tap.keg.name,
        beverage_id: tap.keg.beverage_id,
        status: tap.keg.status,
        started_at: tap.keg.started_at&.iso8601,
        ended_at: tap.keg.ended_at&.iso8601,
        initial_volume: tap.keg.initial_volume,
        final_volume: tap.keg.final_volume
      } : nil,
      flow_meter: tap.flow_meter ? {
        id: tap.flow_meter.id,
        name: tap.flow_meter.name,
        port: tap.flow_meter.port
      } : nil,
      flow_toggle: tap.flow_toggle ? {
        id: tap.flow_toggle.id,
        name: tap.flow_toggle.name,
        port: tap.flow_toggle.port
      } : nil,
      hardware_controller: tap.hardware_controller ? {
        id: tap.hardware_controller.id,
        name: tap.hardware_controller.name,
        device_type: tap.hardware_controller.device_type
      } : nil,
      updated_at: tap.updated_at.iso8601
    }
  end
end
