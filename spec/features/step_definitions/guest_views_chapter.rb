step 'there are 5 trustees' do
  @trustees = (1..5).map { FactoryGirl.create(:user) }
  @trustees.each do |trustee|
    FactoryGirl.create(:role,
                       :user => trustee,
                       :name => 'trustee',
                       :chapter => @current_chapter)
  end
end

step 'I should see the trustees' do
  @trustees.each do |trustee|
    expect(page).to have_selector(".trustee-details h3", :text => "#{trustee.first_name} #{trustee.last_name}")
  end
end

step 'I should not see the trustees' do
  expect(page).to_not have_selector('.trustees')
end
