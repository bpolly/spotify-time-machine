class PlaylistsController < ApplicationController
  breadcrumb 'Playlists', :playlists_path

  def index
    @playlists = Playlist.include(playlist_versions: { songs: :artists }).all
  end

  def show
    @playlist = Playlist.find(params[:id])
    @songs = PlaylistVersionSong.includes(song: :artists).where(playlist_version: @playlist.versions.last).order(position: :asc)

    breadcrumb @playlist.name, playlist_path(@playlist)
  end
end
