require 'rails_helper'

RSpec.describe Playlist do
  it { should have_many(:playlist_versions) }

  describe 'validations' do
    before { FactoryBot.create(:playlist) }
    it { should validate_uniqueness_of(:spotify_id).case_insensitive }
  end

  describe '#version_saved_today?' do
    let(:playlist) { create(:playlist) }

    it 'returns true if there was a version already saved for that day' do
      expect { create(:playlist_version, playlist: playlist) }
        .to change { playlist.version_saved_today? }
        .from(false)
        .to(true)
    end
  end
end
