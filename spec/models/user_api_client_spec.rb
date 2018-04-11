require 'rails_helper'

RSpec.describe UserAPIClient do
  describe '.user_authorization_url' do
    let(:expected_url) do
      'https://accounts.spotify.com/authorize?client_id=test_spotify_client_id&redirect_uri=test_redirect_uri&response_type=code&scope=playlist-modify-public+ugc-image-upload'
    end

    it 'returns the expect url' do
      expect(described_class.user_authorization_url).to eq(expected_url)
    end
  end
end
