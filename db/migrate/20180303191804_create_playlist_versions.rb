class CreatePlaylistVersions < ActiveRecord::Migration[5.1]
  def change
    create_table :playlist_versions do |t|
      t.references :playlist, foreign_key: true

      t.timestamps
    end
  end
end
