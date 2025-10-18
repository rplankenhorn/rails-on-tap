class CreateKegbotSites < ActiveRecord::Migration[8.0]
  def change
    create_table :kegbot_sites do |t|
      t.string :name
      t.string :server_version
      t.boolean :is_setup
      t.text :registration_id
      t.string :volume_display_units
      t.string :temperature_display_units
      t.string :title
      t.string :google_analytics_id
      t.integer :session_timeout_minutes
      t.string :privacy
      t.string :registration_mode
      t.string :timezone
      t.boolean :enable_sensing
      t.boolean :enable_users
      t.text :email_config

      t.timestamps
    end
  end
end
