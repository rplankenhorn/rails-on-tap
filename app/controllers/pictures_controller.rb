class PicturesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_picture, only: [ :show, :destroy ]

  def index
    @pictures = Picture.includes(:user, :drink, :keg, :drinking_session)
                      .order(time: :desc)
                      .page(params[:page])
  end

  def show
  end

  def new
    @picture = Picture.new
    @picture.drink_id = params[:drink_id] if params[:drink_id]
    @picture.user = current_user
    @picture.time = Time.current
  end

  def create
    @picture = Picture.new(picture_params)
    @picture.user = current_user
    @picture.time = Time.current

    if @picture.save
      if @picture.drink
        redirect_to drink_path(@picture.drink), notice: "Picture was successfully added to the drink."
      else
        redirect_to pictures_path, notice: "Picture was successfully created."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    drink = @picture.drink
    @picture.destroy
    if drink
      redirect_to drink_path(drink), notice: "Picture was successfully deleted."
    else
      redirect_to pictures_path, notice: "Picture was successfully deleted."
    end
  end

  private

  def set_picture
    @picture = Picture.find(params[:id])
  end

  def picture_params
    params.require(:picture).permit(:image, :caption, :drink_id, :keg_id, :drinking_session_id)
  end
end
