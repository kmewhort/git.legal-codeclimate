class InitialDb < ActiveRecord::Migration
  def change
    create_table "branches", force: :cascade do |t|
      t.integer "project_id"
    end

    create_table "libraries", force: :cascade do |t|
      t.string  "type"
      t.integer "branch_id"
      t.string  "name"
      t.string  "version"
    end

    add_index "libraries", ["type"], name: "index_libraries_on_type", using: :btree
    add_index "libraries", ["name","version"], name: "index_libraries_on_name_and_version", using: :btree

    create_table "library_dependents", force: :cascade do |t|
      t.string "parent_library_id"
      t.string "child_library_id"
    end

    create_table "license_types", force: :cascade do |t|
      t.string   "title"
      t.float    "version"
      t.string   "identifier"
      t.string   "identifiers",                            array: true
      t.string   "searchable_identifiers",                 array: true
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
      t.integer  "library_id"
      t.integer  "license_type_id"
      t.string   "referencer_type"
      t.string   "referencer_id"
      t.boolean  "unknown_version"
    end

    add_index "licenses", ["library_id"], name: "index_licenses_on_library_id", using: :btree

    create_table "obligations", force: :cascade do |t|
      t.integer "license_type_id"
      t.boolean "obligation_attribution"
      t.boolean "obligation_copyleft"
      t.boolean "obligation_modifiable_form"
      t.boolean "obligation_notice"
    end

    add_index "obligations", ["license_type_id"], name: "index_obligations_on_license_type_id", using: :btree

    create_table "policies", force: :cascade do |t|
      t.integer "project_id"
      t.boolean "allow_affero_copyleft", default: false
      t.boolean "allow_strong_copyleft", default: false
      t.boolean "allow_weak_copyleft",   default: true
      t.boolean "allow_permissive",      default: true
      t.boolean "sublicenses_comply",    default: true
    end

    create_table "projects", force: :cascade do |t|
      t.string  "name"
    end

    create_table "copyleft_clauses", force: :cascade do |t|
      t.integer "license_type_id"
      t.string  "copyleft_applies_to"
      t.string  "copyleft_engages_on"
    end
  end
end
