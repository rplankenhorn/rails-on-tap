class DrinksController < ApplicationController
  before_action :set_drink, only: [ :show, :reassign, :cancel ]

  def index
    @drinks = Drink.includes(:user, { keg: :beverage }, :drinking_session)
                   .order(time: :desc)
                   .page(params[:page])
  end

  def show
    @events = @drink.events.order(time: :desc)
  end

  def reassign
    user = User.find(params[:user_id])
    if @drink.reassign!(user)
      redirect_to @drink, notice: "Drink reassigned to #{user.username}."
    else
      redirect_to @drink, alert: "Failed to reassign drink."
    end
  end

  def cancel
    spilled = params[:spilled] == "true"
    @drink.cancel!(spilled: spilled)
    redirect_to drinks_url, notice: "Drink cancelled."
  end

  private

  def set_drink
    @drink = Drink.find(params[:id])
  end
end
