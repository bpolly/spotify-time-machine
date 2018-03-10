module APIClient
  include HTTParty
  MAX_RETRY_COUNT = 3

  def self.make_authorized_request(url, *objects)
    token = get_token

    (0...MAX_RETRY_COUNT).each do |retry_count|
      response = HTTParty.get(url, headers: {"Authorization" => "Bearer #{token}"})

      if response.success?
        yield(response, *objects)
      elsif response.unauthorized?
        token = get_token(force: true)
      end
    end
  end

  def self.create_new_playlist_version(playlist)
    url = "https://api.spotify.com/v1/users/#{playlist.user_id}/playlists/#{playlist.spotify_id}"
    make_authorized_request(url, playlist) do |response, playlist|
      save_playlist_info(response, playlist)
    end
  end

  def self.get_token(force: false)
    cache = Redis.new
    existing_token = cache.get('spotify_token')
    return existing_token if existing_token && !force

    client_id = ENV["SPOTIFY_CLIENT_ID"]
    client_secret = ENV["SPOTIFY_CLIENT_SECRET"]
    auth = { username: client_id, password: client_secret }
    response = HTTParty.post('https://accounts.spotify.com/api/token',
                          basic_auth: auth,
                          body: { grant_type: 'client_credentials' }
                        )
    new_token = response.parsed_response.fetch('access_token')
    cache.set('spotify_token', new_token)
    new_token
  end

  def self.save_playlist_info(response, playlist)
    PlaylistVersion.transaction do

      # Parse items and see if there has been an update
      parsed_response = JSON.parse(response.body, object_class: OpenStruct)
      playlist_items = parsed_response.tracks.items
      return if no_new_updates?(playlist, playlist_items)

      # Create new version since there are updates
      playlist_version = playlist.versions.create

      # Save playlist artwork
      playlist_artwork_url = parsed_response.images.first.url
      playlist_version.update(
        artwork_url: upload_image_to_s3(playlist_artwork_url, "playlist-version-#{playlist_version.id}"),
        description: parsed_response.description,
        followers: parsed_response.followers.to_i
      )

      # For each track, make new song record if necessary
      playlist_items.each_with_index do |playlist_item, position|
        track = playlist_item.track
        album_id = track.album.id
        album_art_link = track.album.images.last.url

        song = Song.find_or_create_by(
          name: track.name,
          spotify_id: track.id,
          explicit: track.explicit,
          duration_ms: track.duration_ms,
          spotify_uri: track.uri,
          artwork_url: upload_image_to_s3(album_art_link, album_id)
        )

        # create/find artists and associate them to song
        track.artists.each do |artist|
          song.artists.find_or_create_by(
            name: artist.name,
            spotify_id: artist.id,
            spotify_uri: artist.uri
          )
        end

        # add created song to version with position
        playlist_version.playlist_version_songs.create(song: song, position: position)
      end
    end
  end

  def self.upload_image_to_s3(image_link, spotify_id)
    s3_image_url = "https://s3.amazonaws.com/sportcasts.com/#{spotify_id}.png"
    file = Rails.root.join('tmp', "#{spotify_id}.png").to_s
    return s3_image_url if S3_BUCKET.object(File.basename(file)).exists?

    File.open(file, "wb") do |f|
      f.write HTTParty.get(image_link).body
    end

    S3_BUCKET.object(File.basename(file)).upload_file(file, acl: 'public-read')
    File.delete(file) if File.exist?(file)
    s3_image_url
  end

  def self.get_playlist_name(playlist)
    url = "https://api.spotify.com/v1/users/#{playlist.user_id}/playlists/#{playlist.spotify_id}"
    make_authorized_request(url, playlist) do |response, playlist|
      return JSON.parse(response.body, object_class: OpenStruct).name
    end
  end

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

  private

  def self.no_new_updates?(playlist, found_playlist_items)
    return false if playlist.versions.empty?
    return false if found_playlist_items.any? { |item| item.added_at.nil? }
    last_created_at = playlist.versions.last.created_at.utc
    found_playlist_items.all? do |item|
      Time.parse(item.added_at) <= last_created_at
    end
  end
end
