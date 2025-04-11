step 'I attach 3 photos' do
  photos = Rails.root.join("spec", "support", "fixtures")

  attach_file "files[]", (photos / "1.JPG"), make_visible: true
  page.has_css?(".form__image-element-image[title='1.JPG']")

  attach_file "files[]", (photos / "2.JPG"), make_visible: true
  page.has_css?(".form__image-element-image[title='2.JPG']")

  attach_file "files[]", (photos / "3.JPG"), make_visible: true
  page.has_css?(".form__image-element-image[title='3.JPG']")

  click_button("Save")
end

step 'I set the last image to be first' do
  # It's tricky to actually sort the items by dragging, so we just
  # explicitly change the sort_order of the images
  page.execute_script("Object.entries(document.querySelectorAll('.js-uploader__sort-field')).reverse().forEach((el, index) => { el[1].value = index })")

  click_button("Save")
end

step 'I should see that last image when I load the page' do
  filename = File.basename(Photo.find_by("image_data->'metadata'->>'filename' = ?", "3.JPG").url)

  expect(page).to have_selector("#project-gallery > * img", count: 3)
  expect(page).to have_css("#project-gallery .image:first-child img[src*='#{filename}']")
end

step 'I should see :count project image(s) on the page' do |count|
  expect(page).to have_css('#project-gallery .image', count: count.to_i)
end
