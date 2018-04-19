class PlaylistVersionSong < ApplicationRecord
  belongs_to :playlist_version
  belongs_to :song, required: true
  default_scope { order(position: :asc) }
  validates :position, presence: true

  delegate :name, :spotify_id, :explicit, :duration_ms, :spotify_uri, :artwork_url, to: :song
  delegate :artists, to: :song
end
