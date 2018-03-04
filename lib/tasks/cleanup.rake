desc "Deletes all the things"
task cleanup: :environment do
  PlaylistVersion.destroy_all
  Song.destroy_all
  Artist.destroy_all
  Playlist.destroy_all
end
