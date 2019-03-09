# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Set up the admin user
user = User.where(first_name: "Awesome", last_name: "Admin", email: "admin@awesomefoundation.org").first_or_create
user.update_attribute(:admin, true)
user.update_password("gnarly")

# Set up the "Any" Chapter
Chapter.where(name: "Any").first_or_create(description: "Any Chapter", country: COUNTRY_PRIORITY.first)
