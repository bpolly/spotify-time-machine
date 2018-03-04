module APIClient
  include HTTParty
  MAX_RETRY_COUNT = 3

  def self.get_playlist(playlist)
    url = "https://api.spotify.com/v1/users/#{playlist.user_id}/playlists/#{playlist.spotify_id}"
    token = get_token

    (0...MAX_RETRY_COUNT).each do |retry_count|
      response = HTTParty.get(url, headers: {"Authorization" => "Bearer #{token}"})

      if response.success?
        return save_playlist_info(playlist, response)
      elsif response.unauthorized?
        token = get_token(force: true)
      end
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

  def self.save_playlist_info(playlist, response)
    PlaylistVersion.transaction do
      parsed_response = JSON.parse(response.body, object_class: OpenStruct)
      playlist_artwork_url = parsed_response.images.first.url
      playlist_items = parsed_response.tracks.items

      playlist_version = playlist.versions.create
      playlist_version.update(
        artwork_url: upload_image_to_s3(playlist_artwork_url, "playlist-version-#{playlist_version.id}")
      )

      playlist_items.each_with_index do |playlist_item, position|
        track = playlist_item.track
        album_id = track.album.id
        album_art_link = track.album.images.last.url

        # create/find song record
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

        playlist_version.playlist_version_songs.create(song: song, position: position)
      end
    end
  end

  def self.upload_image_to_s3(image_link, spotify_id)
    file = "/tmp/#{spotify_id}.png"
    File.open(file, "wb") do |f|
      f.write HTTParty.get(image_link).body
    end

    S3_BUCKET.object(File.basename(file)).upload_file(file, acl: 'public-read')
    "https://s3.amazonaws.com/sportcasts.com/#{spotify_id}.png"
  end
end
