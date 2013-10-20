# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Set up the admin user
user = User.find_or_create_by_first_name_and_last_name_and_email("Awesome", "Admin", "admin@awesomefoundation.org")
user.update_attribute(:admin, true)
user.update_password("gnarly")

# Set up the "Any" Chapter
Chapter.find_or_create_by_name("Any", description: "Any Chapter", country: COUNTRY_PRIORITY.first)
