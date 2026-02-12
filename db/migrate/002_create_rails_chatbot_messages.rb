class CreateRailsChatbotMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :rails_chatbot_messages do |t|
      t.references :conversation, null: false, foreign_key: { to_table: :rails_chatbot_conversations }, index: true
      t.text :content, null: false
      t.string :role, null: false, default: 'user' # user, assistant, system
      t.json :metadata
      t.timestamps
    end
  end
end
