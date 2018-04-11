class Playlist < ApplicationRecord
  has_many :playlist_versions, dependent: :destroy
  alias_attribute :versions, :playlist_versions
  validates :spotify_id, uniqueness: true, case_sensitive: false

  def version_saved_today?
    versions.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day).exists?
  end
end
