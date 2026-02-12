class CreateRailsChatbotKnowledgeBases < ActiveRecord::Migration[8.0]
  def change
    create_table :rails_chatbot_knowledge_bases do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.string :source_type, null: false # model, page, document, etc.
      t.string :source_id
      t.string :source_url
      t.text :embedding_data # For vector search if needed
      t.timestamps
    end

    add_index :rails_chatbot_knowledge_bases, [:source_type, :source_id]
    add_index :rails_chatbot_knowledge_bases, :title
  end
end
