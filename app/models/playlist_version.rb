class PlaylistVersion < ApplicationRecord
  belongs_to :playlist
  has_many :playlist_version_songs, dependent: :destroy
  has_many :songs, through: :playlist_version_songs
end
