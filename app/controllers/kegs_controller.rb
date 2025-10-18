class KegsController < ApplicationController
  before_action :set_keg, only: [ :show, :edit, :update, :destroy, :attach_to_tap, :end_keg ]

  def index
    @kegs = Keg.includes(beverage: :beverage_producer).order(start_time: :desc)
  end

  def show
    @drinks = @keg.drinks.includes(:user).order(time: :desc).limit(50)
    @sessions = @keg.drinks.includes(:drinking_session).map(&:drinking_session).compact.uniq
  end

  def new
    @keg = Keg.new
    @beverages = Beverage.includes(:beverage_producer).order(:name)
  end

  def create
    @keg = Keg.new(keg_params)
    @keg.status = "available"
    @keg.start_time = Time.current
    @keg.end_time = Time.current

    if @keg.save
      redirect_to @keg, notice: "Keg was successfully created."
    else
      @beverages = Beverage.includes(:beverage_producer).order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @beverages = Beverage.includes(:beverage_producer).order(:name)
  end

  def update
    if @keg.update(keg_params)
      redirect_to @keg, notice: "Keg was successfully updated."
    else
      @beverages = Beverage.includes(:beverage_producer).order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @keg.destroy
    redirect_to kegs_url, notice: "Keg was successfully deleted."
  end

  def attach_to_tap
    tap = KegTap.find(params[:tap_id])
    tap.attach_keg!(@keg)
    redirect_to @keg, notice: "Keg attached to #{tap.name}."
  rescue => e
    redirect_to @keg, alert: "Error: #{e.message}"
  end

  def end_keg
    @keg.end_keg!
    redirect_to @keg, notice: "Keg has been ended."
  end

  def available
    @kegs = Keg.available.includes(beverage: :beverage_producer)
  end

  private

  def set_keg
    @keg = Keg.find(params[:id])
  end

  def keg_params
    params.require(:keg).permit(:beverage_id, :keg_type, :full_volume_ml, :description, :notes)
  end
end
