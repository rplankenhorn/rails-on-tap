class CreateDrinks < ActiveRecord::Migration[8.0]
  def change
    create_table :drinks do |t|
      t.integer :ticks
      t.float :volume_ml
      t.datetime :time
      t.integer :duration
      t.text :shout
      t.text :tick_time_series
      t.references :user, null: false, foreign_key: true
      t.references :keg, null: false, foreign_key: true
      t.references :drinking_session, null: false, foreign_key: true

      t.timestamps
    end
  end
end
