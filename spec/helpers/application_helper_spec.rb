require 'spec_helper'

describe ApplicationHelper, '#display_country?' do

  let(:chapter1) { FactoryGirl.create(:chapter, :country => 'Australia') }
  let(:chapter2) { FactoryGirl.create(:chapter, :country => 'Australia') }
  let(:chapter3) { FactoryGirl.create(:chapter, :country => 'America') }

  it 'returns true/false based on current/previous chapters country' do
    expect(helper.display_country?(chapter1.country)).to be_truthy
    expect(helper.display_country?(chapter2.country)).to be_falsey
    expect(helper.display_country?(chapter3.country)).to be_truthy
  end

end

describe ApplicationHelper, '#markdown' do
  it 'returns markdown converted text' do
    expect(helper.markdown('*Test*')).to eq("<p><em>Test</em></p>\n")
  end

  it 'returns html_safe text' do
    expect(helper.markdown('test')).to be_html_safe
  end
end
