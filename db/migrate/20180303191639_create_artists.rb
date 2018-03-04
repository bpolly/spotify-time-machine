class CreateArtists < ActiveRecord::Migration[5.1]
  def change
    create_table :artists do |t|
      t.string :name
      t.string :spotify_id
      t.string :spotify_uri

      t.timestamps
    end
  end
end
