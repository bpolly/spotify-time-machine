class PlaylistVersionSong < ApplicationRecord
  belongs_to :playlist_version
  belongs_to :song
  default_scope { order(position: :asc) }

  delegate :name, :spotify_id, :explicit, :duration_ms, :spotify_uri, :artwork_url, to: :song
  delegate :artists, to: :song
end
