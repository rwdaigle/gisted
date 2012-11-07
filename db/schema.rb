# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121107020238) do

  create_table "gist_files", :force => true do |t|
    t.integer  "gist_id"
    t.string   "filename"
    t.string   "raw_url"
    t.string   "language"
    t.string   "file_type"
    t.text     "content"
    t.integer  "size_bytes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "gist_files", ["filename"], :name => "index_gist_files_on_filename"
  add_index "gist_files", ["gist_id"], :name => "index_gist_files_on_gist_id"

  create_table "gists", :force => true do |t|
    t.string   "gh_id"
    t.integer  "user_id"
    t.text     "description"
    t.string   "url"
    t.string   "git_pull_url"
    t.string   "git_push_url"
    t.boolean  "public"
    t.integer  "comment_count"
    t.datetime "gh_created_at"
    t.datetime "gh_updated_at"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "gists", ["gh_id"], :name => "index_gists_on_gh_id"
  add_index "gists", ["user_id"], :name => "index_gists_on_user_id"

  create_table "queue_classic_jobs", :force => true do |t|
    t.string   "q_name"
    t.string   "method"
    t.text     "args"
    t.datetime "locked_at"
  end

  add_index "queue_classic_jobs", ["q_name", "id"], :name => "idx_qc_on_name_only_unlocked"

  create_table "users", :force => true do |t|
    t.integer  "gh_id"
    t.string   "gh_username"
    t.string   "gh_email"
    t.string   "gh_name"
    t.string   "gh_oauth_token"
    t.string   "gh_avatar_url"
    t.string   "gh_url"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.datetime "last_gh_fetch"
    t.boolean  "gh_auth_active", :default => true
  end

  add_index "users", ["gh_id"], :name => "index_users_on_gh_id"

end
