class CreateFlowToggles < ActiveRecord::Migration[8.0]
  def change
    create_table :flow_toggles do |t|
      t.string :port_name
      t.references :controller, null: false, foreign_key: { to_table: :hardware_controllers }
      t.references :keg_tap, null: true, foreign_key: true

      t.timestamps
    end

    add_index :flow_toggles, [ :controller_id, :port_name ], unique: true
  end
end
