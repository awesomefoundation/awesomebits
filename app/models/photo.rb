class Photo < ActiveRecord::Base
  belongs_to :project
  has_attached_file :image,
                    :default_style => :main,
                    :styles => {
                      :main => "1440x880#",
                      :index => "500x300#"
                    }

  attr_accessible :image
end
