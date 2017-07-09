step 'I set the winning date to be February 2008' do
  fill_in("project_funded_on", :with => "2008-02-01")
  click_button("Save")
end

step 'I should see the project was funded in February 2008' do
  expect(find('.funded-on').text).to eq("(February 2008)")
end
