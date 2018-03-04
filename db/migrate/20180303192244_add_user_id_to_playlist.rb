class AddUserIdToPlaylist < ActiveRecord::Migration[5.1]
  def change
    add_column :playlists, :user_id, :string
  end
end
