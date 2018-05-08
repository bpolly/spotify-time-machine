require 'rails_helper'

RSpec.describe Song do
  it { should have_and_belong_to_many(:artists) }

  describe 'validations' do
    before { FactoryBot.create(:song) }
    it { should validate_uniqueness_of(:spotify_id).case_insensitive }
    it { should validate_uniqueness_of(:spotify_uri).case_insensitive }
  end
end
