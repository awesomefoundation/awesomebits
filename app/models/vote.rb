class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates_presence_of :user_id
  validates_presence_of :project_id

  validates_uniqueness_of :user_id, :scope => :project_id

  def self.by(user)
    where(:user_id => user.id)
  end

  def self.for(project)
    where(:project_id => project.id)
  end
end
