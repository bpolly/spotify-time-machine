require 'rails_helper'

RSpec.describe Playlist do
  subject { create(:playlist_version) }

  describe '#version_saved_today?' do
    context 'when there is a version created today already' do
      # Some line to test CodeClimate
    end

    context 'when there is no versions created today already' do
    end
  end
end
