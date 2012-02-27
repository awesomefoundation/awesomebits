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
    page.should have_selector(".trustee-details h3", :text => "#{trustee.first_name} #{trustee.last_name}")
  end
end

step 'there is a trustee' do
  @chapter = FactoryGirl.create(:chapter)
  @trustee = FactoryGirl.create(:user, :url => 'http://www.myawesomeblog.com')
  @role = FactoryGirl.create(:role, :user => @trustee, :chapter => @chapter)
end

step 'I should be able to click on a trustee' do
  visit chapter_path(@chapter)
  page.should have_css("a.avatar[href='#{@trustee.url}']")
end
