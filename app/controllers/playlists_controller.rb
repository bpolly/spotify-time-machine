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
      params[:playlist][:spotify_full_uri].split.each do |uri|
        full_uri = uri.split(':')
        user_id = full_uri[2]
        spotify_id = full_uri[4]
        Playlist.create(
          name: PlaylistAPIClient.get_playlist_name(user_id: user_id, spotify_id: spotify_id),
          user_id: user_id,
          spotify_id: spotify_id
        )
      end
    else
      Playlist.create(name: params[:playlist][:name], spotify_id: params[:playlist][:spotify_id])
    end

    flash[:success] = 'Playlist created'
    redirect_back fallback_location: root_path
  end
end
