step 'I attach 3 photos' do
  photos = Rails.root.join("spec", "support", "fixtures")

  # FIXME: The first photo uploaded ends up as the last photo
  # For these tests, we want the photos to be in order 1, 2, 3
  # so we upload them in the reverse order, but this is not
  # a great user experience. This should be changed in the
  # actual app and then in this test.
  find(".new_photo").set(photos + "3.JPG")
  find(".new_photo").set(photos + "2.JPG")
  find(".new_photo").set(photos + "1.JPG")
  click_button("Save")
end

step 'I set the last image to be first' do
  photo_ids = @project.photos.map(&:id)
  # the input is hidden, but it's easier to set it than to deal with drag/drop
  # find("#project_photo_order", visible: false).set([photo_ids[2], photo_ids[0], photo_ids[1]].join(" "))
  # Selenium doesn't let us manipulate a hidden element, so we set it with javascript instead
  page.execute_script("document.getElementById('project_photo_order').value = '#{[photo_ids[2], photo_ids[0], photo_ids[1]].join(' ')}'");
  click_button("Save")
end

step 'I should see that last image when I load the page' do
  expect(page).to have_css("#project-gallery .image:first-child img[src*='3.JPG']")
end

step 'I should see :count project image(s) on the page' do |count|
  expect(page).to have_css('#project-gallery .image', count: count.to_i)
end
