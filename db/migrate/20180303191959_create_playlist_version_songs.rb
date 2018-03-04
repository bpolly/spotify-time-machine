class CreatePlaylistVersionSongs < ActiveRecord::Migration[5.1]
  def change
    create_table :playlist_version_songs do |t|
      t.references :playlist_version, foreign_key: true
      t.references :song, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
