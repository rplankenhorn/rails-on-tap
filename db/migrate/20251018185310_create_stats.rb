class CreateStats < ActiveRecord::Migration[8.0]
  def change
    create_table :stats do |t|
      t.datetime :time
      t.json :stats
      t.boolean :is_first
      t.references :user, null: false, foreign_key: true
      t.references :keg, null: false, foreign_key: true
      t.references :drinking_session, null: false, foreign_key: true
      t.references :drink, null: false, foreign_key: true

      t.timestamps
    end
  end
end
