module RailsChatbot
  module ApplicationHelper
    def rails_chatbot_routes
      routes = {
        conversations_path: rails_chatbot.conversations_path,
        messages_path: rails_chatbot.messages_path,
        conversation_messages_path_template: rails_chatbot.conversation_messages_path(':id')
      }
      routes.to_json.html_safe
    end
  end
end
