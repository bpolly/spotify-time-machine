require 'rails_helper'

RSpec.describe CookieHelper do
  describe '#current_user_name' do
    let(:spotify_user_id) { Faker::Internet.user_name }

    before { helper.request.cookies[:sp_user_id] = spotify_user_id }

    it 'returns the value in cookies[:sp_user_id]' do
      expect(helper.current_user_name).to eq(spotify_user_id)
    end
  end

  describe '#connected_to_spotify?' do
    context 'when the sp_refresh_token key does not exist in cookies' do
      specify { expect(helper.connected_to_spotify?).to be_falsey }
    end

    context 'when the sp_refresh_token key has an empty value in cookies' do
      before { helper.request.cookies[:sp_refresh_token] = '' }
      specify { expect(helper.connected_to_spotify?).to be_falsey }
    end

    context 'when the sp_refresh_token key has any value in cookies' do
      before { helper.request.cookies[:sp_refresh_token] = 'something' }
      specify { expect(helper.connected_to_spotify?).to be_truthy }
    end
  end
end
