class Playlist < ApplicationRecord
  has_many :playlist_versions
  alias_attribute :versions, :playlist_versions
end
