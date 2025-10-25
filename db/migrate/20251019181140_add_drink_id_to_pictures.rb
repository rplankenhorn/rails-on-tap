class AddDrinkIdToPictures < ActiveRecord::Migration[8.0]
  def change
    add_reference :pictures, :drink, null: true, foreign_key: true
  end
end
