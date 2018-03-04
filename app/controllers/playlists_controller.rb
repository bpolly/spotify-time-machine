class PlaylistsController < ApplicationController
  breadcrumb 'Playlists', :playlists_path

  def index
    @playlists = Playlist.all
  end

  def show
    @playlist = Playlist.find(params[:id])

    breadcrumb @playlist.name, playlist_path(@playlist)
  end
end
