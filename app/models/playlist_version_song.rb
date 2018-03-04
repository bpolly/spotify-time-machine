class PlaylistVersionSong < ApplicationRecord
  belongs_to :playlist_version
  belongs_to :song
end
