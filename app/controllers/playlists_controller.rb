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

    breadcrumb 'New', new_playlist_path
  end

  def create
    if params[:playlist][:spotify_full_uri]
      full_uri = params[:playlist][:spotify_full_uri].split(':')
      user_id = full_uri[2]
      spotify_id = full_uri[4]
      p = Playlist.new(
            name: PlaylistAPIClient.get_playlist_name(user_id: user_id, spotify_id: spotify_id),
            user_id: user_id,
            spotify_id: spotify_id
          )
    else
      p = Playlist.new(name: params[:playlist][:name], spotify_id: params[:playlist][:spotify_id])
    end

    if p.save
      redirect_to playlist_path(p)
    else
      render 'new'
    end
  end
end
