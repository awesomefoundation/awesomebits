class ExtraQuestionsOnApplications < ActiveRecord::Migration[4.2]
  def up
    add_column :chapters, :extra_question_1, :string
    add_column :chapters, :extra_question_2, :string
    add_column :chapters, :extra_question_3, :string
    add_column :projects, :extra_question_1, :string
    add_column :projects, :extra_question_2, :string
    add_column :projects, :extra_question_3, :string
    add_column :projects, :extra_answer_1, :text
    add_column :projects, :extra_answer_2, :text
    add_column :projects, :extra_answer_3, :text
  end

  def down
    remove_column :projects, :extra_answer_3
    remove_column :projects, :extra_answer_2
    remove_column :projects, :extra_answer_1
    remove_column :projects, :extra_question_3
    remove_column :projects, :extra_question_2
    remove_column :projects, :extra_question_1
    remove_column :chapters, :extra_question_3
    remove_column :chapters, :extra_question_2
    remove_column :chapters, :extra_question_1
  end
end
