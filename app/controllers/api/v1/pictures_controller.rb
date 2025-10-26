class Api::V1::PicturesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_key

  # POST /api/v1/pictures
  def create
    @picture = Picture.new(picture_params)
    @picture.time = Time.current

    # Set user if username provided
    if params[:username].present?
      @picture.user = User.find_by(username: params[:username])
    end

    if @picture.save
      render json: picture_json(@picture), status: :created
    else
      render json: { errors: @picture.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def picture_params
    params.permit(:image, :caption, :drink_id, :keg_id, :drinking_session_id)
  end

  def picture_json(picture)
    {
      id: picture.id,
      user_id: picture.user_id,
      drink_id: picture.drink_id,
      keg_id: picture.keg_id,
      drinking_session_id: picture.drinking_session_id,
      caption: picture.caption,
      time: picture.time.iso8601,
      image_url: picture.image.attached? ? rails_storage_proxy_url(picture.image) : nil,
      user: picture.user ? { id: picture.user.id, username: picture.user.username } : nil
    }
  end
end
