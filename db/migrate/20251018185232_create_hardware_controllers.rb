class CreateHardwareControllers < ActiveRecord::Migration[8.0]
  def change
    create_table :hardware_controllers do |t|
      t.string :name
      t.string :controller_model_name
      t.string :serial_number

      t.timestamps
    end
  end
end
