FactoryBot.define do
  factory :playlist do
    name { Faker::SiliconValley.invention }
    spotify_id { Faker::Number.number(4).to_s }
    spotify_uri { Faker::Food.description }
    user_id { 'spotify' }
  end
end
