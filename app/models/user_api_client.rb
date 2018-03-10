module UserAPIClient
  include HTTParty
  require 'open-uri'
  require 'base64'

  def self.get_user_authorization_url
    url = 'https://accounts.spotify.com/authorize'
    client_id = ENV["SPOTIFY_CLIENT_ID"]
    params = {
      client_id: client_id,
      response_type: 'code',
      redirect_uri: ENV['REDIRECT_URI'],
      scope: 'playlist-modify-public ugc-image-upload'
    }
    "#{url}?#{params.to_query}"
  end

  def self.request_user_tokens(authorization_token)
    url = 'https://accounts.spotify.com/api/token'
    params = {
      grant_type: 'authorization_code',
      code: authorization_token,
      redirect_uri: ENV['REDIRECT_URI']
    }
    client_id = ENV["SPOTIFY_CLIENT_ID"]
    client_secret = ENV["SPOTIFY_CLIENT_SECRET"]
    auth = { username: client_id, password: client_secret }
    HTTParty.post(url, basic_auth: auth, body: params)
  end

  def self.save_playlist_version_to_user_profile(user_id:, access_token:, playlist_version:)
    url = "https://api.spotify.com/v1/users/#{user_id}/playlists"
    headers = {
      "Authorization" => "Bearer #{access_token}",
      "Content-Type" => "application/json"
    }
    body = {
      name: playlist_version.save_name,
      description: playlist_version.description
    }
    response = HTTParty.post(url, headers: headers, body: body.to_json)
    playlist_id = JSON.parse(response.body, object_class: OpenStruct).id
    if(playlist_id)
      save_tracks_to_playlist(
        playlist_version: playlist_version,
        playlist_id: playlist_id,
        access_token: access_token,
        user_id: user_id
      )
      save_artwork_to_playlist(
        playlist_version: playlist_version,
        playlist_id: playlist_id,
        access_token: access_token,
        user_id: user_id
      )
    end
  end

  def self.get_spotify_user_id(access_token)
    url = 'https://api.spotify.com/v1/me'
    response = HTTParty.get(url, headers: {"Authorization" => "Bearer #{access_token}"})
    JSON.parse(response.body, object_class: OpenStruct).id
  end

  def self.refresh_access_token(refresh_token)
    url = 'https://accounts.spotify.com/api/token'
    params = {
      grant_type: 'refresh_token',
      refresh_token: refresh_token
    }
    client_id = ENV["SPOTIFY_CLIENT_ID"]
    client_secret = ENV["SPOTIFY_CLIENT_SECRET"]
    auth = { username: client_id, password: client_secret }
    response = HTTParty.post(url, body: params, basic_auth: auth)
    JSON.parse(response.body, object_class: OpenStruct).access_token
  end

  def self.save_tracks_to_playlist(playlist_version:, playlist_id:, access_token:, user_id:)
    url = "https://api.spotify.com/v1/users/#{user_id}/playlists/#{playlist_id}/tracks"
    headers = {
      "Authorization" => "Bearer #{access_token}",
      "Content-Type" => "application/json"
    }
    body = { uris: playlist_version.songs.map(&:spotify_uri) }
    response = HTTParty.post(url, headers: headers, body: body.to_json)
  end

  def self.save_artwork_to_playlist(playlist_version:, playlist_id:, access_token:, user_id:)
    url = "https://api.spotify.com/v1/users/#{user_id}/playlists/#{playlist_id}/images"
    headers = {
      "Authorization" => "Bearer #{access_token}",
      "Content-Type" => "image/jpeg"
    }
    body = Base64.strict_encode64(open(playlist_version.artwork_url).read)
    response = HTTParty.put(url, headers: headers, body: body)
  end
end
