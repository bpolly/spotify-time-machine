module PlaylistAPIClient
  include HTTParty
  MAX_RETRY_COUNT = 3

  def self.get_playlist_information(playlist)
    if playlist.version_saved_today?
      Rollbar.info('Duplicate playlist version attempted to be created',
                   playlist: "#{playlist.id} - #{playlist.name}")
      return
    end
    url = "https://api.spotify.com/v1/users/#{playlist.user_id}/playlists/#{playlist.spotify_id}"
    make_authorized_request(url)
  end

  def self.make_authorized_request(url)
    token = get_token

    (0...MAX_RETRY_COUNT).each do |_retry_count|
      response = HTTParty.get(url, headers: { 'Authorization' => "Bearer #{token}" })
      return response if response.success?
      token = get_token(force: true)
    end
    false
  end

  def self.get_token(force: false)
    cache = Redis.new
    existing_token = cache.get('spotify_token')
    return existing_token if existing_token && !force
    auth = { username: ENV['SPOTIFY_CLIENT_ID'], password: ENV['SPOTIFY_CLIENT_SECRET'] }
    response = HTTParty.post('https://accounts.spotify.com/api/token',
                             basic_auth: auth,
                             body: { grant_type: 'client_credentials' })
    new_token = response.parsed_response.fetch('access_token')
    cache.set('spotify_token', new_token) && cache.quit
    new_token
  end

  def self.get_playlist_name(user_id:, spotify_id:)
    url = "https://api.spotify.com/v1/users/#{user_id}/playlists/#{spotify_id}"
    response = make_authorized_request(url)
    return JSON.parse(response.body, object_class: OpenStruct).name if response
  end
end
