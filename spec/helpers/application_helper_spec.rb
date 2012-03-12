require 'spec_helper'

describe ApplicationHelper do

  let(:chapter1) { FactoryGirl.create(:chapter, :country => 'Australia') }
  let(:chapter2) { FactoryGirl.create(:chapter, :country => 'Australia') }
  let(:chapter3) { FactoryGirl.create(:chapter, :country => 'America') }

  it 'returns true/false based on current/previous chapters country' do
    helper.display_country?(chapter1.country).should be_true
    helper.display_country?(chapter2.country).should be_false
    helper.display_country?(chapter3.country).should be_true
  end

end
