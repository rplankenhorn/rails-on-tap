class CreateKegs < ActiveRecord::Migration[8.0]
  def change
    create_table :kegs do |t|
      t.string :keg_type
      t.float :served_volume_ml
      t.float :full_volume_ml
      t.datetime :start_time
      t.datetime :end_time
      t.string :status
      t.text :description
      t.float :spilled_ml
      t.text :notes
      t.references :beverage, null: false, foreign_key: true

      t.timestamps
    end
  end
end
