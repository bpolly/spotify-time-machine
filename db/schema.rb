# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180304032818) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.string "spotify_id"
    t.string "spotify_uri"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artists_songs", id: false, force: :cascade do |t|
    t.bigint "song_id", null: false
    t.bigint "artist_id", null: false
    t.index ["artist_id", "song_id"], name: "index_artists_songs_on_artist_id_and_song_id"
    t.index ["song_id", "artist_id"], name: "index_artists_songs_on_song_id_and_artist_id"
  end

  create_table "playlist_version_songs", force: :cascade do |t|
    t.bigint "playlist_version_id"
    t.bigint "song_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["playlist_version_id"], name: "index_playlist_version_songs_on_playlist_version_id"
    t.index ["song_id"], name: "index_playlist_version_songs_on_song_id"
  end

  create_table "playlist_versions", force: :cascade do |t|
    t.bigint "playlist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "artwork_url"
    t.index ["playlist_id"], name: "index_playlist_versions_on_playlist_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.string "name"
    t.string "spotify_id"
    t.string "spotify_uri"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_id"
  end

  create_table "songs", force: :cascade do |t|
    t.string "name"
    t.string "spotify_id"
    t.boolean "explicit"
    t.integer "duration_ms"
    t.string "spotify_uri"
    t.string "artwork_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "playlist_version_songs", "playlist_versions"
  add_foreign_key "playlist_version_songs", "songs"
  add_foreign_key "playlist_versions", "playlists"
end