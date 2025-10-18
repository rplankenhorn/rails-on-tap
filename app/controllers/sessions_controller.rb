class SessionsController < ApplicationController
  def index
    @sessions = DrinkingSession.includes(drinks: :user).order(start_time: :desc).page(params[:page])
  end

  def show
    @session = DrinkingSession.find(params[:id])
    @drinks = @session.drinks.includes(:user, keg: :beverage).order(time: :asc)
    @pictures = @session.pictures.order(time: :desc)
  end
end
