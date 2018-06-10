class ArtistsController < ApplicationController
  breadcrumb 'Artist', :artists_path

  def index
    @artist = Artist.all
  end

  def show
    @artist = Artist.find(params[:id])
    @playlist_versions = PlaylistVersionSong.where(song: @artist.songs).map(&:playlist_version)

    breadcrumb @artist.name, playlist_path(@artist)
  end
end
