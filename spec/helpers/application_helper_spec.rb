require 'spec_helper'

describe ApplicationHelper, '#display_country?' do

  let(:chapter1) { FactoryGirl.create(:chapter, :country => 'Australia') }
  let(:chapter2) { FactoryGirl.create(:chapter, :country => 'Australia') }
  let(:chapter3) { FactoryGirl.create(:chapter, :country => 'America') }

  it 'returns true/false based on current/previous chapters country' do
    helper.display_country?(chapter1.country).should be_truthy
    helper.display_country?(chapter2.country).should be_falsey
    helper.display_country?(chapter3.country).should be_truthy
  end

end

describe ApplicationHelper, '#markdown' do
  it 'returns markdown converted text' do
    helper.markdown('*Test*').should == "<p><em>Test</em></p>\n"
  end

  it 'returns html_safe text' do
    helper.markdown('test').should be_html_safe
  end
end
