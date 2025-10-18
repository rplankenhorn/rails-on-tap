class CreateThermoSensors < ActiveRecord::Migration[8.0]
  def change
    create_table :thermo_sensors do |t|
      t.string :raw_name
      t.string :nice_name

      t.timestamps
    end
  end
end
