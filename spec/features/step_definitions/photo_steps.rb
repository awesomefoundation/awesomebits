step 'I attach 3 photos' do
  photos = Rails.root.join("spec", "support", "fixtures")
  find(".new_photo").set(photos + "1.jpg")
  find(".new_photo").set(photos + "2.jpg")
  find(".new_photo").set(photos + "3.jpg")
  click_button("Save")
end

step 'I should see the three photos in the carousel' do
  page.should have_css("#project-gallery img[src*='1.jpg']")
  page.should have_css("#project-gallery img[src*='2.jpg']")
  page.should have_css("#project-gallery img[src*='3.jpg']")
end
