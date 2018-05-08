require 'rails_helper'

RSpec.describe Artist do
  it { should have_and_belong_to_many(:songs) }

  describe 'validations' do
    before { FactoryBot.create(:artist) }
    it { should validate_uniqueness_of(:spotify_id).case_insensitive }
    it { should validate_uniqueness_of(:spotify_uri).case_insensitive }
  end
end
