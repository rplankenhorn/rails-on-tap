class ChangeSystemEventsUserIdToOptional < ActiveRecord::Migration[8.0]
  def change
    change_column_null :system_events, :user_id, true
  end
end
