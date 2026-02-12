module RailsChatbot
  class Message < ApplicationRecord
    self.table_name = 'rails_chatbot_messages'

    belongs_to :conversation, class_name: 'RailsChatbot::Conversation'

    validates :content, presence: true
    validates :role, inclusion: { in: %w[user assistant system] }

    scope :user_messages, -> { where(role: 'user') }
    scope :assistant_messages, -> { where(role: 'assistant') }
  end
end
