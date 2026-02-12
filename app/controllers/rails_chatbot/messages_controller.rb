module RailsChatbot
  class MessagesController < ApplicationController
    before_action :set_conversation

    def create
      user_message = params[:message].to_s.strip

      if user_message.blank?
        render json: { error: 'Message cannot be blank' }, status: :unprocessable_entity
        return
      end

      chat_service = ChatService.new(conversation: @conversation)
      result = chat_service.process_message(user_message)

      render json: {
        message: {
          role: 'assistant',
          content: result[:response],
          created_at: Time.current
        },
        knowledge_sources: result[:knowledge_sources].map do |source|
          {
            title: source[:title],
            source_type: source[:source_type],
            source_id: source[:source_id],
            source_url: source[:source_url]
          }
        end
      }
    rescue => e
      Rails.logger.error("Chat error: #{e.message}\n#{e.backtrace.join("\n")}")
      render json: { error: 'An error occurred while processing your message' }, status: :internal_server_error
    end

    private

    def set_conversation
      conversation_id = params[:conversation_id] || params[:conversation][:id] rescue nil
      
      if conversation_id
        @conversation = Conversation.find_by!(id: conversation_id, session_id: session_id)
      else
        @conversation = Conversation.find_or_create_by(session_id: session_id) do |conv|
          conv.title = "Conversation #{Time.current.strftime('%Y-%m-%d %H:%M')}"
          conv.user = current_user if respond_to?(:current_user) && current_user
        end
      end
    end

    def session_id
      @session_id ||= session[:chatbot_session_id] ||= SecureRandom.uuid
    end
  end
end
