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

  describe '.request_user_tokens' do
    let(:authorization_token) { SecureRandom.uuid }

    it 'makes an API request to fetch user tokens' do
      expect(HTTParty).to receive(:post).with(
        'https://accounts.spotify.com/api/token',
        basic_auth: { username: ENV['SPOTIFY_CLIENT_ID'], password: ENV['SPOTIFY_CLIENT_SECRET'] },
        body: {
          grant_type: 'authorization_code',
          code: authorization_token,
          redirect_uri: ENV['REDIRECT_URI']
        }
      )
      described_class.request_user_tokens(authorization_token)
    end
  end

  describe 'save_playlist_version_to_user_profile' do
    let(:user_id) { SecureRandom.uuid }
    let(:access_token) { SecureRandom.uuid }
    let(:playlist_version) { create(:playlist_version) }
    let(:spotify_playlist_id) { SecureRandom.uuid }

    before do
      allow(described_class).to receive(:create_playlist_for_user).and_return(spotify_playlist_id)
    end

    it 'creates a playlist on the users account' do
      expect(described_class).to receive(:create_playlist_for_user).with(
        user_id: user_id,
        access_token: access_token,
        playlist_version: playlist_version
      )
      described_class.save_playlist_version_to_user_profile(
        user_id: user_id,
        access_token: access_token,
        playlist_version: playlist_version
      )
    end

    it 'adds tracks to the playlist on the users account' do
      expect(described_class).to receive(:save_tracks_to_playlist).with(
        user_id: user_id,
        access_token: access_token,
        playlist_version: playlist_version,
        spotify_playlist_id: spotify_playlist_id
      )
      described_class.save_playlist_version_to_user_profile(
        user_id: user_id,
        access_token: access_token,
        playlist_version: playlist_version
      )
    end

    it 'saves the playlist artwork' do
      expect(described_class).to receive(:save_artwork_to_playlist).with(
        user_id: user_id,
        access_token: access_token,
        playlist_version: playlist_version,
        spotify_playlist_id: spotify_playlist_id
      )
      described_class.save_playlist_version_to_user_profile(
        user_id: user_id,
        access_token: access_token,
        playlist_version: playlist_version
      )
    end
  end

  describe '.create_playlist_for_user' do
    let(:stub) {}
    let(:user_id) { SecureRandom.uuid }
    let(:access_token) { SecureRandom.uuid }
    let(:playlist_version) { create(:playlist_version) }

    before do
    end

    it 'makes a POST request to the users playlist route' do
      stub = stub_request(:post, "https://api.spotify.com/v1/users/#{user_id}/playlists").
        with(body: { name: playlist_version.save_name, description: playlist_version.description },
             headers: { 'Authorization' => "Bearer #{access_token}", 'Content-Type' => 'application/json'}
           )
      described_class.create_playlist_for_user(user_id: user_id, access_token: access_token, playlist_version: playlist_version)
      expect(stub).to have_been_requested
    end

    # it 'returns the playlist ID received'

  end
end
