FactoryBot.define do
  factory :playlist_version do
    status 'Waiting'
    active false
    idle false
    association :playlist
    artwork_url
    description
    followers
  end
end
