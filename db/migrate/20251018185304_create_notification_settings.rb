class CreateNotificationSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_settings do |t|
      t.boolean :keg_tapped
      t.boolean :session_started
      t.boolean :keg_volume_low
      t.boolean :keg_ended
      t.string :backend
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
