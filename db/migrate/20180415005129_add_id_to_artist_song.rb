class AddIdToArtistSong < ActiveRecord::Migration[5.1]
  def change
    add_column :artists_songs, :id, :primary_key
  end
end
