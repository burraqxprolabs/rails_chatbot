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

ActiveRecord::Schema[8.1].define(version: 3) do
  create_table "rails_chatbot_conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "session_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "user_type"
    t.index ["session_id"], name: "index_rails_chatbot_conversations_on_session_id"
    t.index ["user_type", "user_id"], name: "index_rails_chatbot_conversations_on_user"
  end

  create_table "rails_chatbot_knowledge_bases", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.text "embedding_data"
    t.string "source_id"
    t.string "source_type", null: false
    t.string "source_url"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["source_type", "source_id"], name: "idx_on_source_type_source_id_2f0220aebf"
    t.index ["title"], name: "index_rails_chatbot_knowledge_bases_on_title"
  end

  create_table "rails_chatbot_messages", force: :cascade do |t|
    t.text "content", null: false
    t.integer "conversation_id", null: false
    t.datetime "created_at", null: false
    t.json "metadata"
    t.string "role", default: "user", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_rails_chatbot_messages_on_conversation_id"
  end

  add_foreign_key "rails_chatbot_messages", "rails_chatbot_conversations", column: "conversation_id"
end
