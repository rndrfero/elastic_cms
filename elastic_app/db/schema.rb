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

ActiveRecord::Schema.define(:version => 20120427151555) do

  create_table "elastic_sites", :force => true do |t|
    t.string   "host"
    t.string   "title"
    t.text     "locales"
    t.string   "theme"
    t.text     "meta_keywords"
    t.text     "meta_description"
    t.string   "index_locale"
    t.text     "locale_to_index_hash"
    t.boolean  "is_force_reload_theme"
    t.boolean  "is_locked"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "elastic_sites", ["host"], :name => "index_elastic_sites_on_host"

end
