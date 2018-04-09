require 'rails_helper'

RSpec.describe PlaylistVersion do
  subject { create(:playlist_version) }

  describe '#formatted_date' do
    let(:created_at) { Time.zone.parse('2018 March 21') }
    before { subject.update(created_at: created_at) }

    specify { expect(subject.formatted_date).to eq('March 21, 2018') }
  end

  describe '#save_name' do
    let(:playlist_name) { 'Good Vibes' }
    let(:created_at) { Time.zone.parse('2018 April 8') }
    let(:expected_name) { 'Good Vibes - 04-08-2018' }

    before do
      subject.playlist.update(name: playlist_name)
      subject.update(created_at: created_at)
    end

    specify { expect(subject.save_name).to eq(expected_name) }
  end
end
