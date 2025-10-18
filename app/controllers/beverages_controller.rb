class BeveragesController < ApplicationController
  before_action :set_beverage, only: [ :show, :edit, :update, :destroy ]

  def index
    @beverages = Beverage.includes(:beverage_producer)
                         .order("beverages.name")
                         .page(params[:page])
  end

  def show
    @kegs = @beverage.kegs.includes(:keg_tap).order(start_time: :desc).limit(10)
  end

  def new
    @beverage = Beverage.new
    @producers = BeverageProducer.order(:name)
  end

  def create
    @beverage = Beverage.new(beverage_params)

    if @beverage.save
      redirect_to @beverage, notice: "Beverage created successfully."
    else
      @producers = BeverageProducer.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @producers = BeverageProducer.order(:name)
  end

  def update
    if @beverage.update(beverage_params)
      redirect_to @beverage, notice: "Beverage updated successfully."
    else
      @producers = BeverageProducer.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @beverage.destroy
    redirect_to beverages_url, notice: "Beverage deleted successfully."
  end

  def search
    query = params[:q]
    @beverages = Beverage.includes(:beverage_producer)
                         .where("beverages.name LIKE ? OR beverages.style LIKE ?", "%#{query}%", "%#{query}%")
                         .order("beverages.name")
                         .limit(20)

    render json: @beverages.as_json(include: { beverage_producer: { only: [ :id, :name ] } })
  end

  private

  def set_beverage
    @beverage = Beverage.find(params[:id])
  end

  def beverage_params
    params.require(:beverage).permit(
      :name, :beverage_producer_id, :style, :abv_percent, :ibu, :color_srm,
      :original_gravity, :final_gravity, :calories_oz, :carbohydrates_oz,
      :description, :vintage_year, :logo_image
    )
  end
end
