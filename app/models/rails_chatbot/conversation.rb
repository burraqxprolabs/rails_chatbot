module RailsChatbot
  class Conversation < ApplicationRecord
    self.table_name = 'rails_chatbot_conversations'

    has_many :messages, dependent: :destroy, class_name: 'RailsChatbot::Message'

    validates :session_id, presence: true

    scope :recent, -> { order(created_at: :desc) }

    def add_user_message(content)
      messages.create!(content: content, role: 'user')
    end

    def add_assistant_message(content, metadata: {})
      messages.create!(content: content, role: 'assistant', metadata: metadata)
    end

    def conversation_history
      messages.order(created_at: :asc).map do |msg|
        { role: msg.role, content: msg.content }
      end
    end
  end
end
