class PlaylistVersion < ApplicationRecord
  belongs_to :playlist
  has_many :playlist_version_songs, dependent: :destroy
  alias_attribute :songs, :playlist_version_songs

  def formatted_date
    created_at.strftime("%B %d, %Y")
  end

  def save_name
    "#{playlist.name} - #{created_at.strftime('%m-%d-%Y')}"
  end
end
