class Photo < ActiveRecord::Base
  belongs_to :project
  has_attached_file :image

  attr_accessible :image
end
