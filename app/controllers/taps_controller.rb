class TapsController < ApplicationController
  before_action :set_tap, only: [ :show, :edit, :update, :attach_keg, :detach_keg ]

  def index
    @taps = KegTap.includes({ current_keg: :beverage }, :temperature_sensor).order(:sort_order)
  end

  def show
    @current_temperature = @tap.current_temperature
    @recent_temps = @tap.temperature_sensor&.thermologs&.order(time: :desc)&.limit(24) || []
  end

  def new
    @tap = KegTap.new
  end

  def create
    @tap = KegTap.new(tap_params)

    if @tap.save
      redirect_to @tap, notice: "Tap was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @tap.update(tap_params)
      redirect_to @tap, notice: "Tap was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def attach_keg
    keg = Keg.find(params[:keg_id])
    @tap.attach_keg!(keg)
    redirect_to @tap, notice: "Keg attached successfully."
  rescue => e
    redirect_to @tap, alert: "Error: #{e.message}"
  end

  def detach_keg
    @tap.end_current_keg!
    redirect_to @tap, notice: "Keg detached successfully."
  end

  private

  def set_tap
    @tap = KegTap.find(params[:id])
  end

  def tap_params
    params.require(:keg_tap).permit(:name, :notes, :sort_order)
  end
end
