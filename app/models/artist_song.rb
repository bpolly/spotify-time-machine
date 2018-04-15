class ArtistSong < ApplicationRecord
  self.table_name = 'artists_songs'
  belongs_to :song
  belongs_to :artist
end
