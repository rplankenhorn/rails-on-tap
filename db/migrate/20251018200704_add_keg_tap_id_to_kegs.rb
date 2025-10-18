class AddKegTapIdToKegs < ActiveRecord::Migration[8.0]
  def change
    add_reference :kegs, :keg_tap, null: true, foreign_key: true, index: true
  end
end
