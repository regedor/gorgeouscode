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

ActiveRecord::Schema.define(version: 20161014134111) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "code_coverage_analyses", force: :cascade do |t|
    t.float    "percent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "github_accounts", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "model_diagram_analyses", force: :cascade do |t|
    t.text     "json_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string   "github_url"
    t.string   "github_owner"
    t.string   "github_name"
    t.integer  "github_forks"
    t.integer  "github_watchers"
    t.integer  "github_size"
    t.boolean  "github_private"
    t.string   "github_homepage"
    t.text     "github_description"
    t.boolean  "github_fork"
    t.boolean  "github_has_wiki"
    t.boolean  "github_has_issues"
    t.integer  "github_open_issues"
    t.date     "github_pushed_at"
    t.date     "github_created_at"
    t.text     "github_collaborators"
    t.boolean  "has_last_report_analyses", default: false
    t.date     "analyse_updated_at"
    t.date     "github_info_updated_at"
    t.integer  "added_by_user_id"
    t.integer  "owner_user_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "github_secret_token"
    t.integer  "github_webhook_id"
    t.integer  "github_account_id"
  end

  add_index "projects", ["github_account_id"], name: "index_projects_on_github_account_id", using: :btree

  create_table "rails_best_practices_analyses", force: :cascade do |t|
    t.float    "score"
    t.text     "nbp_report"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reports", force: :cascade do |t|
    t.string   "commit_hash"
    t.string   "branch"
    t.string   "rails_app_path"
    t.text     "gc_config"
    t.string   "ruby_version"
    t.date     "queued_at"
    t.date     "started_at"
    t.date     "finished_setup_at"
    t.date     "finished_at"
    t.integer  "project_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "rails_best_practices_analysis_id"
    t.integer  "model_diagram_analysis_id"
    t.integer  "code_coverage_analysis_id"
  end

  add_index "reports", ["code_coverage_analysis_id"], name: "index_reports_on_code_coverage_analysis_id", using: :btree
  add_index "reports", ["model_diagram_analysis_id"], name: "index_reports_on_model_diagram_analysis_id", using: :btree
  add_index "reports", ["project_id"], name: "index_reports_on_project_id", using: :btree
  add_index "reports", ["rails_best_practices_analysis_id"], name: "index_reports_on_rails_best_practices_analysis_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "gender"
    t.string   "facebook_photo_url"
    t.string   "google_photo_url"
    t.string   "github_photo_url"
    t.string   "github_nickname"
    t.string   "github_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "projects", "github_accounts"
  add_foreign_key "reports", "code_coverage_analyses"
  add_foreign_key "reports", "model_diagram_analyses"
  add_foreign_key "reports", "projects"
  add_foreign_key "reports", "rails_best_practices_analyses"
end
