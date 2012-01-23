class AwesomeFoundationSchema < ActiveRecord::Migration
  create_table "chapters", :force => true do |t|
    t.string "name"
    t.string "slug"
    t.text   "body"
    t.string "tagline"
    t.string "submission_form_url"
  end

  create_table "projects", :force => true do |t|
    t.string   "title",              :null => false
    t.string   "url"
    t.string   "status",             :null => false
    t.date     "funded_at",          :null => false
    t.integer  "chapter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description",        :null => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
  end

  add_index "projects", ["chapter_id", "status", "funded_at"], :name => "index_projects_on_chapter_id_and_status_and_funded_at"

  create_table "submissions", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "email"
    t.string   "phone"
    t.text     "description"
    t.integer  "chapter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "use"
    t.string   "title"
  end

  add_index "submissions", ["chapter_id"], :name => "index_submissions_on_chapter_id"

  create_table "users", :force => true do |t|
    t.string   "login",                                 :null => false
    t.string   "email"
    t.string   "crypted_password",                      :null => false
    t.string   "password_salt",                         :null => false
    t.string   "persistence_token",                     :null => false
    t.string   "perishable_token",                      :null => false
    t.boolean  "active",             :default => true
    t.integer  "login_count",        :default => 0,     :null => false
    t.integer  "failed_login_count", :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.boolean  "admin",              :default => false
    t.string   "first_name",                            :null => false
    t.string   "last_name",                             :null => false
    t.text     "bio"
    t.string   "url"
    t.string   "twitter_username"
    t.string   "facebook_url"
    t.string   "linkedin_url"
    t.integer  "chapter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["chapter_id"], :name => "index_users_on_chapter_id"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"
end
