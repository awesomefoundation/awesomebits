class Project < ActiveRecord::Base
  belongs_to :chapter

  validates_presence_of :title
  validates_presence_of :status
  validates_presence_of :description
end
