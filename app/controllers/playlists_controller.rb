class PlaylistsController < ApplicationController
  breadcrumb 'Playlists', :playlists_path

  def index
    @playlists = Playlist.include(playlist_versions: { songs: :artists }).all
  end

  def show
    @playlist = Playlist.find(params[:id])

    breadcrumb @playlist.name, playlist_path(@playlist)
  end
end
