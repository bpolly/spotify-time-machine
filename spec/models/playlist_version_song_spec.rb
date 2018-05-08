require 'rails_helper'

RSpec.describe PlaylistVersionSong do
  it { belong_to(:playlist_version) }
  it { belong_to(:song) }
  it { should delegate_method(:name).to(:song) }
  it { should delegate_method(:spotify_id).to(:song) }
  it { should delegate_method(:explicit).to(:song) }
  it { should delegate_method(:duration_ms).to(:song) }
  it { should delegate_method(:spotify_uri).to(:song) }
  it { should delegate_method(:artwork_url).to(:song) }
  it { should delegate_method(:artists).to(:song) }
end
