class User < ActiveRecord::Base
  include Clearance::User
  attr_accessible :email, :password
end
