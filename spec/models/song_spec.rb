require 'rails_helper'

RSpec.describe Song do
  it { should have_and_belong_to_many(:artists) }
end
