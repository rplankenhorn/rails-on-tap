class CreateInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :invitations do |t|
      t.string :invite_code
      t.string :for_email
      t.datetime :invited_date
      t.datetime :expires_date
      t.references :invited_by, null: false, foreign_key: true

      t.timestamps
    end
  end
end
