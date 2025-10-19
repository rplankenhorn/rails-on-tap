class AddFlowMeterToKegTaps < ActiveRecord::Migration[8.0]
  def change
    add_reference :keg_taps, :meter, null: true, foreign_key: { to_table: :flow_meters }
  end
end
