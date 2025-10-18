class BeverageProducersController < ApplicationController
  before_action :set_producer, only: [ :show, :edit, :update, :destroy ]

  def index
    @producers = BeverageProducer.order(:name).page(params[:page])
  end

  def show
    @beverages = @producer.beverages.order(:name)
  end

  def new
    @producer = BeverageProducer.new
  end

  def create
    @producer = BeverageProducer.new(producer_params)

    if @producer.save
      redirect_to @producer, notice: "Producer created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @producer.update(producer_params)
      redirect_to @producer, notice: "Producer updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @producer.destroy
    redirect_to beverage_producers_url, notice: "Producer deleted successfully."
  end

  private

  def set_producer
    @producer = BeverageProducer.find(params[:id])
  end

  def producer_params
    params.require(:beverage_producer).permit(
      :name, :country, :origin_state, :origin_city, :description,
      :url, :logo_image, :is_homebrew
    )
  end
end
