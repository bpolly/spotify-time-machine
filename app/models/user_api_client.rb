module UserAPIClient
  include HTTParty

  def self.get_user_authorization_url
    url = 'https://accounts.spotify.com/authorize'
    client_id = ENV["SPOTIFY_CLIENT_ID"]
    params = {
      client_id: client_id,
      response_type: 'code',
      redirect_uri: ENV['REDIRECT_URI'],
      scope: 'playlist-modify-public'
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

  def self.create_playlist_for_user(user_id:, access_token:, playlist_name:)
    url = "https://api.spotify.com/v1/users/#{user_id}/playlists"
    headers = {
      "Authorization" => "Bearer #{access_token}",
      "Content-Type" => "application/json"
    }
    body = {
      name: playlist_name,
      description: 'Created using the Spotify Time Machine'
    }
    HTTParty.post(url, headers: headers, body: body.to_json)

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
end
