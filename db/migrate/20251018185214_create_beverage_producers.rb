class CreateBeverageProducers < ActiveRecord::Migration[8.0]
  def change
    create_table :beverage_producers do |t|
      t.string :name
      t.string :country
      t.string :origin_state
      t.string :origin_city
      t.boolean :is_homebrew
      t.string :url
      t.text :description
      t.string :beverage_backend
      t.string :beverage_backend_id

      t.timestamps
    end
  end
end
