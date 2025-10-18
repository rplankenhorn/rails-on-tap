class DashboardController < ApplicationController
  def index
    @site = KegbotSite.get
    @active_taps = KegTap.includes(current_keg: :beverage).where.not(current_keg_id: nil).order(:sort_order)
    @recent_drinks = Drink.includes(:user, keg: :beverage).order(time: :desc).limit(10)
    @active_sessions = DrinkingSession.where("end_time > ?", Time.current).order(start_time: :desc).limit(5)
    @recent_events = SystemEvent.includes(:user, :keg, :drink).order(time: :desc).limit(20)

    # Statistics
    @total_drinks = Drink.count
    @total_volume_liters = Drink.sum(:volume_ml) / 1000.0
    @active_kegs_count = Keg.where(status: "on_tap").count
    @total_users = User.count
  end
end
