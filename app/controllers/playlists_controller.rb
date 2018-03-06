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

  def create
    if params[:spotify_full_uri]
      full_uri = params[:spotify_full_uri].split(':')
      p = playlist.new(
            user_id: full_uri[2],
            spotify_uri = full_uri[4]
          )
      p.update(name: APIClient.get_playlist_name(p))
    end
  end
end
