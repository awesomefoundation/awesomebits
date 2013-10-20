step 'I set the winning date to be February, 2008' do
  fill_in("Funded on", with: "2008-02-01")
  click_button("Save")
end

step 'I should see the project was funded in February, 2008' do
  find('.funded-on').text.should == "(February, 2008)"
end
