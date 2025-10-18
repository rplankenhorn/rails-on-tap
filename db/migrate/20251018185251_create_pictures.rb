class CreatePictures < ActiveRecord::Migration[8.0]
  def change
    create_table :pictures do |t|
      t.text :caption
      t.datetime :time
      t.references :user, null: false, foreign_key: true
      t.references :keg, null: false, foreign_key: true
      t.references :drinking_session, null: false, foreign_key: true

      t.timestamps
    end
  end
end
