FactoryGirl.define do
  factory :playlist_version do
    status 'Waiting'
    active false
    idle false
    playlist_id
    created_at
    updated_at
    artwork_url
    description
    followers
  end
end
