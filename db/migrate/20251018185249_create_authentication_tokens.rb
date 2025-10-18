class CreateAuthenticationTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :authentication_tokens do |t|
      t.string :auth_device
      t.string :token_value
      t.string :nice_name
      t.string :pin
      t.boolean :enabled
      t.datetime :expire_time
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
