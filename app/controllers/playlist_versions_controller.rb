class PlaylistVersionsController < ApplicationController
  breadcrumb 'Playlists', :playlists_path

  def index
    @playlists = Playlist.all
  end

  def show
    @playlist = Playlist.find(params[:playlist_id])
    @playlist_version = @playlist.versions.find(params[:id])
    @songs = PlaylistVersionSong.includes(song: :artists).where(playlist_version: @playlist.versions.last).order(position: :asc)

    breadcrumb @playlist.name, playlist_path(@playlist)
    breadcrumb @playlist_version.formatted_date, playlist_version_path(@playlist, @playlist_version)
  end

  def new
    @playlist = Playlist.new
  end

  def save_to_profile
    APIClient.create_playlist_for_user(spotify_user_id)
  end
end
