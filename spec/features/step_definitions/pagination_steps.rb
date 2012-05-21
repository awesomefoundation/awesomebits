step 'I follow the link to the next page' do
  go_to_next_page
end

step 'I should see pagination links' do
  page.should have_css('div.pagination')
end
