module PlaylistAPIClient
  include HTTParty
  MAX_RETRY_COUNT = 3

  def self.make_authorized_request(url, *objects)
    token = get_token

    (0...MAX_RETRY_COUNT).each do |_retry_count|
      response = HTTParty.get(url, headers: { 'Authorization' => "Bearer #{token}" })

      return yield(response, *objects) if response.success?
      token = get_token(force: true)
    end
  end

  def self.create_new_playlist_version(playlist)
    url = "https://api.spotify.com/v1/users/#{playlist.user_id}/playlists/#{playlist.spotify_id}"
    make_authorized_request(url, playlist) do |response|
      save_playlist_info(response, playlist)
    end
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

  def self.save_playlist_info(response, playlist)
    return if playlist.version_saved_today?
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
        artwork_url: upload_image_to_s3(
          playlist_artwork_url,
          "playlist-version-#{playlist_version.id}"
        ),
        description: parsed_response.description,
        followers: parsed_response.followers.to_i
      )

      # For each track, make new song record if necessary
      save_artists_and_songs_for_playlist_version(
        playlist_version: playlist_version,
        playlist_items: playlist_items
      )
    end
  end

  def self.upload_image_to_s3(image_link, spotify_id)
    s3_image_url = "https://#{ENV['S3_BUCKET']}.s3.amazonaws.com/#{spotify_id}.png"
    file = Rails.root.join('tmp', "#{spotify_id}.png").to_s
    return s3_image_url if S3_BUCKET.object(File.basename(file)).exists?

    File.open(file, 'wb') do |f|
      f.write HTTParty.get(image_link).body
    end

    S3_BUCKET.object(File.basename(file)).upload_file(file, acl: 'public-read')
    File.delete(file) if File.exist?(file)
    s3_image_url
  end

  def self.get_playlist_name(user_id:, spotify_id:)
    url = "https://api.spotify.com/v1/users/#{user_id}/playlists/#{spotify_id}"
    make_authorized_request(url) do |response, _playlist|
      return JSON.parse(response.body, object_class: OpenStruct).name
    end
  end

  # rubocop:disable Metrics/AbcSize
  def self.save_artists_and_songs_for_playlist_version(playlist_version:, playlist_items:)
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
        song.artists << Artist.find_or_create_by(
          name: artist.name,
          spotify_id: artist.id,
          spotify_uri: artist.uri
        )
      end

      # add created song to version with position
      playlist_version.playlist_version_songs.create(song: song, position: position)
    end
  end

  def self.no_new_updates?(playlist, found_playlist_items)
    return false if playlist.versions.empty?
    return false if found_playlist_items.any? { |item| item.added_at.nil? }
    last_created_at = playlist.versions.last.created_at.utc
    found_playlist_items.all? do |item|
      Time.zone.parse(item.added_at) <= last_created_at
    end
  end
  private_class_method :no_new_updates?
end
