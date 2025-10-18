class CreateBeverages < ActiveRecord::Migration[8.0]
  def change
    create_table :beverages do |t|
      t.string :name
      t.string :beverage_type
      t.string :style
      t.text :description
      t.date :vintage_year
      t.float :abv_percent
      t.float :calories_per_ml
      t.float :carbs_per_ml
      t.string :color_hex
      t.float :original_gravity
      t.float :specific_gravity
      t.float :srm
      t.float :ibu
      t.float :star_rating
      t.integer :untappd_beer_id
      t.string :beverage_backend
      t.string :beverage_backend_id
      t.references :beverage_producer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
