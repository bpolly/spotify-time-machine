class PlaylistsController < ApplicationController
  breadcrumb 'Playlists', :playlists_path

  def index
    @playlists = Playlist.all
  end

  def show
    @playlist = Playlist.find(params[:id])
    redirect_to playlist_version_path(@playlist, @playlist.versions.last)
  end

  def new
    @playlist = Playlist.new
  end
end
