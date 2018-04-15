FactoryBot.define do
  factory :artist do
    name { Faker::SiliconValley.invention }
    spotify_id { Faker::Number.number(4).to_s }
    spotify_uri { Faker::Food.description }
  end
end
