require 'spec_helper'

describe 'funded_projects/show' do
  let!(:funded_project) { FactoryGirl.create(:project, funded_on: Time.zone.now.to_date, funded_description: "I am a funded project") }
    
  it 'displays the funded description for a funded project' do 
    assign(:project, funded_project)
    view.stubs(:current_user).returns(Guest.new)

    render
    expect(rendered).to have_content(funded_project.funded_description)
  end
end
