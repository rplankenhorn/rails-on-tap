class CreateDevices < ActiveRecord::Migration[8.0]
  def change
    create_table :devices do |t|
      t.string :name
      t.datetime :created_time

      t.timestamps
    end
  end
end
