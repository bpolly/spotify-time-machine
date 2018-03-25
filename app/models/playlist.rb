class Playlist < ApplicationRecord
  has_many :playlist_versions
  alias_attribute :versions, :playlist_versions
  validates :spotify_id, uniqueness: true

  def version_saved_today?
    versions.where(created_at: Time.now.beginning_of_day..Time.now.end_of_day).exists?
  end
end
