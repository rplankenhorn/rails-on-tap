class CreateKegTaps < ActiveRecord::Migration[8.0]
  def change
    create_table :keg_taps do |t|
      t.string :name
      t.text :notes
      t.integer :sort_order
      t.references :current_keg, null: true, foreign_key: { to_table: :kegs }
      t.references :temperature_sensor, null: true, foreign_key: { to_table: :thermo_sensors }

      t.timestamps
    end
  end
end
