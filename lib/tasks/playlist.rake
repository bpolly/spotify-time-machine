namespace :playlist do
  desc "Fetches new versions of playlists"
  task update_all: :environment do
    Playlist.all.each do |playlist|
      APIClient.get_playlist(playlist)
    end
  end

end