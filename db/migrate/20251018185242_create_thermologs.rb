class CreateThermologs < ActiveRecord::Migration[8.0]
  def change
    create_table :thermologs do |t|
      t.float :temp
      t.datetime :time
      t.references :thermo_sensor, null: false, foreign_key: true

      t.timestamps
    end
  end
end
