# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101015153012) do

  create_table "groups", :force => true do |t|
    t.string   "department"
    t.string   "name"
    t.integer  "manager_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "homeworks", :force => true do |t|
    t.datetime "check_in"
    t.datetime "check_out"
    t.integer  "working_day_id"
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login"
    t.integer  "duration"
    t.string   "status"
  end

  create_table "records", :force => true do |t|
    t.string   "login"
    t.datetime "click_date"
    t.integer  "working_day_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "type"
    t.string   "login"
    t.string   "email"
    t.string   "name"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "working_days", :force => true do |t|
    t.string   "login"
    t.datetime "check_in"
    t.datetime "check_out"
    t.integer  "duration"
    t.date     "wday"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
