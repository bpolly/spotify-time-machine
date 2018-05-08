FactoryBot.define do
  factory :playlist_version do
    association :playlist
    artwork_url { Faker::Internet.url }
    description { Faker::Seinfeld.quote }
    followers { Faker::Number.number(4) }
  end
end
