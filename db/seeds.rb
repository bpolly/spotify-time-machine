# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Playlist.find_or_create_by(
  user_id: 'spotify',
  name: 'New Music Friday',
  spotify_id: '37i9dQZF1DX4JAvHpjipBk'
)

Playlist.find_or_create_by(
  user_id: 'spotify',
  name: "Today's Top Hits",
  spotify_id: '37i9dQZF1DXcBWIGoYBM5M'
)
