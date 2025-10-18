class CreatePluginData < ActiveRecord::Migration[8.0]
  def change
    create_table :plugin_data do |t|
      t.string :plugin_name
      t.string :key
      t.json :value

      t.timestamps
    end
  end
end
