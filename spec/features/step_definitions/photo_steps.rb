step 'I attach 3 photos' do
  photos = Rails.root.join("spec", "support", "fixtures")
  find(".new_photo").set(photos + "1.jpg")
  find(".new_photo").set(photos + "2.jpg")
  find(".new_photo").set(photos + "3.jpg")
  click_button("Save")
end

step 'I should see the three photos in the carousel' do
  expect(page).to have_css("#project-gallery img[src*='1.jpg']")
  expect(page).to have_css("#project-gallery img[src*='2.jpg']")
  expect(page).to have_css("#project-gallery img[src*='3.jpg']")
end

step 'I set the last image to be first' do
  photo_ids = @project.photos.map(&:id)
  # the input is hidden, but it's easier to set it than to deal with drag/drop
  find("#project_photo_order", visible: false).set([photo_ids[2], photo_ids[0], photo_ids[1]].join(" "))
  click_button("Save")
end

step 'I should see that last image when I load the page' do
  expect(page).to have_css(".project-gallery img[src*='3.jpg']:not(.faded)")
end
