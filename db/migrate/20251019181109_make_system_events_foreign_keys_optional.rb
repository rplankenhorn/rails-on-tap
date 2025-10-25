class MakeSystemEventsForeignKeysOptional < ActiveRecord::Migration[8.0]
  def change
    change_column_null :system_events, :drink_id, true
    change_column_null :system_events, :keg_id, true
    change_column_null :system_events, :drinking_session_id, true
  end
end
