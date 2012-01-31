step 'some projects are from this month' do
  @projects_this_month = FactoryGirl.create(:project, :chapter => @current_chapter)
end

step 'some projects are from last month' do
  @projects_last_month = FactoryGirl.create(:project,
                                            :chapter => @current_chapter,
                                            :created_at => 35.days.ago)
end

step 'some projects are from this month, but for a different chapter' do
  @projects_other_chapter = FactoryGirl.create(:project,
                                               :chapter => FactoryGirl.create(:chapter))
end

step 'some projects are from this month, but for any chapter' do
  @projects_other_chapter = FactoryGirl.create(:project,
                                               :chapter => Chapter.find_by_name("Any"))
end

step 'I go to the projects index' do
  visit projects_path
end
