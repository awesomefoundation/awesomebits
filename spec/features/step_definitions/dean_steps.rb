step 'there is a dean in the system' do
  @dean_role    = FactoryBot.create(:role, :name => 'dean')
  @dean         = @dean_role.user
  @dean_chapter = @dean_role.chapter
end
