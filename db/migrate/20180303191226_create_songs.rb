class CreateSongs < ActiveRecord::Migration[5.1]
  def change
    create_table :songs do |t|
      t.string :name
      t.string :spotify_id
      t.boolean :explicit
      t.integer :duration_ms
      t.string :spotify_uri
      t.string :artwork_url

      t.timestamps
    end
  end
end
