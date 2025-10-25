class MakePicturesForeignKeysOptional < ActiveRecord::Migration[8.0]
  def change
    change_column_null :pictures, :user_id, true
    change_column_null :pictures, :keg_id, true
    change_column_null :pictures, :drinking_session_id, true
  end
end
