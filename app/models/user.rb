class User < ActiveRecord::Base
  include Clearance::User
  attr_accessible :email, :password

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :encrypted_password

  has_many :roles
  has_many :chapters, :through => :roles

  def name
    [first_name, last_name].map(&:to_s).join(" ").strip
  end

end

