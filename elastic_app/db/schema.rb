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

ActiveRecord::Schema.define(:version => 20120427161020) do

  create_table "elastic_content_configs", :force => true do |t|
    t.string   "title"
    t.integer  "position"
    t.integer  "section_id"
    t.string   "form"
    t.string   "mime"
    t.text     "meta"
    t.boolean  "is_offline"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "elastic_contents", :force => true do |t|
    t.text     "text"
    t.binary   "binary"
    t.integer  "content_config_id"
    t.text     "meta"
    t.text     "locale"
    t.integer  "node_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "elastic_nodes", :force => true do |t|
    t.string   "title"
    t.string   "title_loc"
    t.string   "link"
    t.integer  "section_id"
    t.integer  "site_id"
    t.text     "meta_keywords"
    t.text     "meta_description"
    t.string   "locale"
    t.string   "key"
    t.boolean  "is_star"
    t.boolean  "is_published"
    t.integer  "node_id"
    t.integer  "position"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "ancestry"
    t.integer  "ancestry_depth"
  end

  add_index "elastic_nodes", ["ancestry"], :name => "index_elastic_nodes_on_ancestry"
  add_index "elastic_nodes", ["key"], :name => "index_elastic_nodes_on_key"
  add_index "elastic_nodes", ["section_id"], :name => "index_elastic_nodes_on_section_id"

  create_table "elastic_sections", :force => true do |t|
    t.string   "title"
    t.string   "localization"
    t.integer  "site_id"
    t.string   "key"
    t.boolean  "is_locked"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "elastic_sections", ["key"], :name => "index_elastic_sections_on_key"

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

  create_table "elastic_template_caches", :force => true do |t|
    t.string   "ident"
    t.binary   "template"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "elastic_template_caches", ["ident"], :name => "index_elastic_template_caches_on_ident"

end
