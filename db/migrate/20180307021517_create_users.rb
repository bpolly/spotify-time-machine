class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.timestamps null: false
      t.string :email, null: false
      t.string :encrypted_password, limit: 128, null: false
      t.string :confirmation_token, limit: 128
      t.string :remember_token, limit: 128, null: false
      t.string :spotify_user_id
      t.string :access_token
      t.string :refresh_token
    end

    add_index :users, :email
    add_index :users, :remember_token
  end
end
