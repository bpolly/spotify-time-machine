FactoryBot.define do
  factory :song do
    name { Faker::Book.title }
    spotify_id { Faker::Number.number(4).to_s }
    explicit { Faker::Boolean.boolean }
    duration_ms { Faker::Number.number(5).to_s }
    spotify_uri { Faker::Internet.password(8) }
    artwork_url { Faker::Internet.url }
  end
end
