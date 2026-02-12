class CreateRailsChatbotConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :rails_chatbot_conversations do |t|
      t.string :session_id, null: false, index: true
      t.references :user, polymorphic: true, null: true, index: true
      t.string :title
      t.timestamps
    end
  end
end
