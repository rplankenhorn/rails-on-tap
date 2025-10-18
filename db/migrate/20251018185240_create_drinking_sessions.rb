class CreateDrinkingSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :drinking_sessions do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.float :volume_ml
      t.string :timezone
      t.string :name

      t.timestamps
    end
  end
end
