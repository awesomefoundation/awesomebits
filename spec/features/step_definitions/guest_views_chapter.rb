step 'there are 5 trustees' do
  @trustees = (1..5).map { create(:user) }
  @trustees.each do |trustee|
    create(:role,
                       user: trustee,
                       name: 'trustee',
                       chapter: @current_chapter)
  end
end

step 'I should see the trustees' do
  @trustees.each do |trustee|
    page.should have_selector(".trustee-details h3", text: "#{trustee.first_name} #{trustee.last_name}")
  end
end
