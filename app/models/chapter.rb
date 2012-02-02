class Chapter < ActiveRecord::Base
  has_many :roles
  has_many :users, :through => :roles
  has_many :projects
  has_many :invitations

  validates_uniqueness_of :name

  attr_accessible :name, :twitter_url, :facebook_url, :blog_url, :description
end
