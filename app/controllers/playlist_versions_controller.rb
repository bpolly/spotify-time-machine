class PlaylistVersionsController < ApplicationController
  breadcrumb 'Playlists', :playlists_path

  def index
    @playlists = Playlist.all
  end

  def show
    @playlist = Playlist.find(params[:playlist_id])
    @playlist_version = PlaylistVersion.find(params[:id])
    @songs = PlaylistVersionSong.includes(song: :artists).where(playlist_version: @playlist_version).order(position: :asc)

    breadcrumb @playlist.name, playlist_path(@playlist)
    breadcrumb @playlist_version.formatted_date, playlist_version_path(@playlist, @playlist_version)
  end

  def new
    @playlist = Playlist.new
  end

  def save_to_profile
    @playlist_version = PlaylistVersion.find(params[:id])
    spotify_user_id = cookies[:sp_user_id] || UserAPIClient.get_spotify_user_id(access_token)
    result = UserAPIClient.save_playlist_version_to_user_profile(
      user_id: spotify_user_id,
      access_token: user_access_token,
      playlist_version: @playlist_version
    )
    respond_to { |format| format.js } if result
  end
end
