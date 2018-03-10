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
    spotify_user_id = cookies[:sp_user_id] || APIClient.get_spotify_user_id(access_token)
    APIClient.create_playlist_for_user(
      user_id: spotify_user_id,
      access_token: user_access_token,
      playlist_name: @playlist_version.save_name)
  end
end
