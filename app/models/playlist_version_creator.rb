class PlaylistVersionCreator
  attr_reader :playlist, :playlist_data, :playlist_version

  PlaylistInfoFetchError = Class.new(StandardError)

  def initialize(playlist:)
    @playlist = playlist
    @playlist_data = fetch_playlist_data!
  end

  def fetch_playlist_data!
    response = PlaylistAPIClient.get_playlist_information(playlist)
    raise PlaylistInfoFetchError unless response.success?
    JSON.parse(response.body, object_class: OpenStruct)
  end

  def save!
    playlist_items = playlist_data.tracks.items
    return if no_new_updates?(playlist_items)

    PlaylistVersion.transaction do
      create_playlist_version!
      add_songs_to_playlist_version!
    end
  end

  def create_playlist_version!
    @playlist_version = playlist.versions.create!(
      description: playlist_data.description,
      followers: playlist_data.followers.to_i
    )

    # Save playlist artwork
    playlist_version.tap do |pv|
      pv.update!(artwork_url: ImageUploader.upload_to_s3(
        image_link: playlist_data.images.first.url,
        filename: "playlist-version-#{playlist_version.id}"
      ))
    end
  end

  def add_songs_to_playlist_version!
    playlist_data.tracks.items.each_with_index do |playlist_item, position|
      track = playlist_item.track
      song = find_or_create_song!(track: track)

      # create/find artists and associate them to song
      track.artists.each do |artist_item|
        artist = Artist.find_or_create_by!(
          name: artist_item.name,
          spotify_id: artist_item.id,
          spotify_uri: artist_item.uri
        )
        song.artists << artist unless song.artists.include?(artist)
      end

      # add created song to version with position
      playlist_version.playlist_version_songs.create!(song: song, position: position)
    end
  end

  def find_or_create_song!(track:)
    existing_song = Song.find_by(spotify_id: track.id)
    return existing_song if existing_song
    Song.create!(
      name: track.name,
      spotify_id: track.id,
      explicit: track.explicit,
      duration_ms: track.duration_ms,
      spotify_uri: track.uri,
      artwork_url: ImageUploader.upload_to_s3(
        image_link: track.album.images.last.url,
        filename: track.album.id
      )
    )
  end

  def no_new_updates?(found_playlist_items)
    last_playlist_version = playlist.versions.last
    return false if playlist.versions.empty?
    return false if found_playlist_items.any? { |item| item.added_at.nil? }
    found_playlist_items.each_with_index do |item, position|
      if last_playlist_version.songs.find_by(position: position).spotify_id != item.track.spotify_id
        return false
      end
    end
    true
  end
end
