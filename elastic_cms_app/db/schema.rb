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

ActiveRecord::Schema.define(:version => 20120530084812) do

  create_table "elastic_content_configs", :force => true do |t|
    t.string   "title"
    t.integer  "position"
    t.integer  "section_id"
    t.string   "form"
    t.string   "mime"
    t.text     "meta"
    t.boolean  "is_published"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "elastic_contents", :force => true do |t|
    t.text     "text"
    t.integer  "reference_id"
    t.string   "reference_type"
    t.text     "published_text"
    t.integer  "published_reference_id"
    t.string   "published_reference_type"
    t.integer  "content_config_id"
    t.text     "locale"
    t.integer  "node_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "elastic_file_records", :force => true do |t|
    t.string   "title"
    t.text     "text"
    t.integer  "gallery_id"
    t.string   "ino"
    t.string   "filename"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "elastic_galleries", :force => true do |t|
    t.string   "title"
    t.string   "key"
    t.integer  "site_id"
    t.integer  "node_id"
    t.boolean  "is_star"
    t.boolean  "is_watermarked"
    t.boolean  "is_timestamped"
    t.boolean  "is_hidden"
    t.boolean  "is_locked"
    t.text     "meta"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "elastic_galleries", ["site_id"], :name => "index_elastic_galleries_on_site_id"

  create_table "elastic_identities", :force => true do |t|
    t.string   "uid"
    t.string   "provider"
    t.integer  "user_id"
    t.string   "password_digest"
    t.string   "email"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "elastic_identities", ["user_id"], :name => "index_elastic_identities_on_user_id"

  create_table "elastic_nodes", :force => true do |t|
    t.string   "title"
    t.string   "title_loc"
    t.string   "link"
    t.string   "redirect"
    t.integer  "section_id"
    t.integer  "site_id"
    t.text     "meta_keywords"
    t.text     "meta_description"
    t.string   "locale"
    t.string   "key"
    t.boolean  "is_star"
    t.boolean  "is_locked"
    t.boolean  "is_published"
    t.integer  "node_id"
    t.integer  "position"
    t.integer  "version_cnt"
    t.datetime "published_at"
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
    t.boolean  "is_star"
    t.boolean  "is_hidden"
    t.boolean  "is_locked"
    t.string   "form"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "elastic_sections", ["key"], :name => "index_elastic_sections_on_key"

  create_table "elastic_sites", :force => true do |t|
    t.string   "host"
    t.string   "title"
    t.string   "key"
    t.text     "locales"
    t.string   "theme"
    t.string   "theme_index"
    t.string   "theme_layout"
    t.text     "meta_keywords"
    t.text     "meta_description"
    t.string   "index_locale"
    t.text     "locale_to_index_hash"
    t.boolean  "is_force_reload_theme"
    t.boolean  "is_locked"
    t.integer  "gallery_id"
    t.integer  "master_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.text     "galleries_meta"
  end

  add_index "elastic_sites", ["host"], :name => "index_elastic_sites_on_host"

  create_table "elastic_template_caches", :force => true do |t|
    t.string   "ident"
    t.binary   "template"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "elastic_template_caches", ["ident"], :name => "index_elastic_template_caches_on_ident"

  create_table "elastic_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.string   "name"
    t.integer  "site_id"
    t.string   "locale"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "elastic_users", ["authentication_token"], :name => "index_elastic_users_on_authentication_token", :unique => true
  add_index "elastic_users", ["email"], :name => "index_elastic_users_on_email", :unique => true
  add_index "elastic_users", ["reset_password_token"], :name => "index_elastic_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
