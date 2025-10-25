class UsersController < ApplicationController
  before_action :set_user, only: [ :show, :stats ]

  def index
    @users = User.active.order(username: :asc).page(params[:page])
  end

  def show
    @recent_drinks = @user.drinks.includes({ keg: :beverage }, :pictures)
                         .order(time: :desc)
                         .limit(10)
    @total_volume = @user.drinks.sum(:volume_ml)
    @drink_count = @user.drinks.count
  end

  def stats
    # User statistics page (can be expanded later)
    @drinks = @user.drinks.includes({ keg: :beverage })
                   .order(time: :desc)
    @total_volume = @drinks.sum(:volume_ml)
    @favorite_beers = @drinks.group(:keg_id)
                            .count
                            .sort_by { |_, v| -v }
                            .first(5)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
