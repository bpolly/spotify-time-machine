class PlaylistVersion < ApplicationRecord
  belongs_to :playlist
  has_many :playlist_version_songs, dependent: :destroy
  alias_attribute :songs, :playlist_version_songs
end
