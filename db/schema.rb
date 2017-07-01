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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170701051245) do

  create_table "branches", force: :cascade do |t|
    t.integer "project_id"
  end

  create_table "copyleft_clauses", force: :cascade do |t|
    t.integer "license_type_id"
    t.string  "copyleft_applies_to"
    t.string  "copyleft_engages_on"
  end

  create_table "libraries", force: :cascade do |t|
    t.string  "type"
    t.integer "branch_id"
    t.string  "name"
    t.string  "version"
  end

  add_index "libraries", ["name", "version"], name: "index_libraries_on_name_and_version"
  add_index "libraries", ["type"], name: "index_libraries_on_type"

  create_table "library_dependents", force: :cascade do |t|
    t.string "parent_library_id"
    t.string "child_library_id"
  end

  create_table "license_type_policies", force: :cascade do |t|
    t.integer "policy_id"
    t.integer "license_type_id"
    t.string  "treatment"
  end

  add_index "license_type_policies", ["license_type_id"], name: "index_license_type_policies_on_license_type_id"
  add_index "license_type_policies", ["policy_id"], name: "index_license_type_policies_on_policy_id"

  create_table "license_types", force: :cascade do |t|
    t.string   "title"
    t.float    "version"
    t.string   "identifier"
    t.string   "identifiers"
    t.string   "searchable_identifiers"
    t.boolean  "unverified",             default: true
    t.boolean  "domain_content"
    t.boolean  "domain_data"
    t.boolean  "domain_software"
    t.string   "maintainer_type"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "text_file_name"
    t.string   "text_content_type"
    t.integer  "text_file_size"
    t.datetime "text_updated_at"
    t.string   "maintainer"
    t.boolean  "confirmed",              default: false
  end

  create_table "licenses", force: :cascade do |t|
    t.integer "library_id"
    t.integer "license_type_id"
    t.string  "referencer_type"
    t.string  "referencer_id"
    t.boolean "unknown_version"
  end

  add_index "licenses", ["library_id"], name: "index_licenses_on_library_id"

  create_table "obligations", force: :cascade do |t|
    t.integer "license_type_id"
    t.boolean "obligation_attribution"
    t.boolean "obligation_copyleft"
    t.boolean "obligation_modifiable_form"
    t.boolean "obligation_notice"
  end

  add_index "obligations", ["license_type_id"], name: "index_obligations_on_license_type_id"

  create_table "policies", force: :cascade do |t|
    t.integer "project_id"
    t.boolean "allow_affero_copyleft",   default: false
    t.boolean "allow_strong_copyleft",   default: false
    t.boolean "allow_weak_copyleft",     default: true
    t.boolean "allow_permissive",        default: true
    t.boolean "sublicenses_comply",      default: true
    t.boolean "allow_unknown_libraries", default: true
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
  end

end
