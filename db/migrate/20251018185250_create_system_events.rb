class CreateSystemEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :system_events do |t|
      t.string :kind
      t.datetime :time
      t.references :user, null: false, foreign_key: true
      t.references :drink, null: false, foreign_key: true
      t.references :keg, null: false, foreign_key: true
      t.references :drinking_session, null: false, foreign_key: true

      t.timestamps
    end
  end
end
