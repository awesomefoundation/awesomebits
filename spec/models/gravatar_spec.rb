require 'spec_helper'

describe Gravatar do
  context 'given an email' do
    let(:gravatar) { Gravatar.new("HELLO@example.com  ") }
    it 'should generate the hash that gravatar needs' do
      expect(gravatar.hash).to eq("cb8419c1d471d55fbca0d63d1fb2b6ac")
    end

    it 'should generate the url that will get the gravatar' do
      expect(gravatar.url).to eq("https://www.gravatar.com/avatar/cb8419c1d471d55fbca0d63d1fb2b6ac?d=retro&s=134")
    end
  end
end
