namespace :playlist do
  desc 'Fetches new versions of playlists'
  task update_all: :environment do
    Playlist.all.each do |playlist|
      PlaylistVersionCreator.new(playlist: playlist).save!
    end
  end
end
