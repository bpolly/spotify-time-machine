class AddDescriptionAndFollowersToPlaylistVersions < ActiveRecord::Migration[5.1]
  def change
    add_column :playlist_versions, :description, :text
    add_column :playlist_versions, :followers, :integer
  end
end
