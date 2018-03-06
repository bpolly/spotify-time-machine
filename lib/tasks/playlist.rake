namespace :playlist do
  desc "Fetches new versions of playlists"
  task update_all: :environment do
    Playlist.all.each do |playlist|
      APIClient.create_new_playlist_version(playlist)
    end
  end

end
