class AddFullTextIndexToProjects < ActiveRecord::Migration[4.2]

  COLUMN = [:name, :title, :about_me, :about_project, :use_for_money,
              :extra_answer_1, :extra_answer_2, :extra_answer_3]

  def up
    COLUMN.each do |column|
      execute("create index index_projects_to_tsvector_on_#{column} on projects using gin(to_tsvector('english', #{column}))")
    end
  end

  def down
    COLUMN.each do |column|
      execute("drop index index_projects_to_tsvector_on_#{column}")
    end
  end

end
