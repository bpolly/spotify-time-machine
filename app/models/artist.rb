class Artist < ApplicationRecord
  has_and_belongs_to_many :songs
  validates :spotify_id, uniqueness: { case_sensitive: false }
  validates :spotify_uri, uniqueness: { case_sensitive: false }
end
