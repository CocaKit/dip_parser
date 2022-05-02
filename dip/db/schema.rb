# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_05_02_100802) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "litres_books", force: :cascade do |t|
    t.string "main_genre"
    t.string "name"
    t.string "author"
    t.string "series"
    t.float "grade_litres"
    t.float "grade_livelib"
    t.integer "evaluators_litres"
    t.integer "evaluators_livelib"
    t.string "genres", array: true
    t.string "tags", array: true
    t.integer "age_limit"
    t.integer "release_on_website"
    t.integer "release_on_world"
    t.integer "release_translate"
    t.integer "book_size"
    t.string "isbn"
    t.float "price"
    t.text "description"
    t.string "page_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_litres_books_on_name"
  end

  create_table "parse_tasks", force: :cascade do |t|
    t.string "name"
    t.integer "web_site"
    t.integer "status"
    t.string "category_names", array: true
    t.string "page_urls", array: true
    t.date "finish_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
