class ArtistsController < ApplicationController
  breadcrumb 'Artist', :artists_path

  def index
    @artist = Artist.all
  end

  def show
    @artist = Artist.find(params[:id])

    breadcrumb @artist.name, playlist_path(@artist)
  end
end
