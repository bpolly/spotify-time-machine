class AddArtworkUrlToPlaylistVersions < ActiveRecord::Migration[5.1]
  def change
    add_column :playlist_versions, :artwork_url, :string
  end
end
