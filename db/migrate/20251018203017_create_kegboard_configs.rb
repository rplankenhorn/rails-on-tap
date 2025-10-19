class CreateKegboardConfigs < ActiveRecord::Migration[8.0]
  def change
    create_table :kegboard_configs do |t|
      t.string :name, null: false
      t.string :config_type, null: false, default: "mqtt"
      t.string :mqtt_broker
      t.integer :mqtt_port, default: 1883
      t.string :mqtt_username
      t.string :mqtt_password
      t.string :mqtt_topic_prefix, default: "kegbot"
      t.boolean :enabled, default: true

      t.timestamps
    end

    add_index :kegboard_configs, :name, unique: true
    add_index :kegboard_configs, :enabled
  end
end
