module RailsChatbot
  class ConversationsController < ApplicationController
    before_action :set_conversation, only: [:show, :destroy]

    def index
      @conversations = Conversation.where(session_id: session_id)
                                   .recent
                                   .limit(20)
      render json: @conversations.map { |c| { id: c.id, title: c.title, created_at: c.created_at } }
    end

    def show
      @messages = @conversation.messages.order(created_at: :asc)
      render json: {
        conversation: {
          id: @conversation.id,
          title: @conversation.title,
          created_at: @conversation.created_at
        },
        messages: @messages.map { |m| { role: m.role, content: m.content, created_at: m.created_at } }
      }
    end

    def create
      @conversation = Conversation.find_or_create_by(session_id: session_id) do |conv|
        conv.title = params[:title] || "Conversation #{Time.current.strftime('%Y-%m-%d %H:%M')}"
        conv.user = current_user if respond_to?(:current_user) && current_user
      end

      render json: { conversation_id: @conversation.id, title: @conversation.title }
    end

    def destroy
      @conversation.destroy
      head :no_content
    end

    private

    def set_conversation
      @conversation = Conversation.find_by!(id: params[:id], session_id: session_id)
    end

    def session_id
      @session_id ||= session[:chatbot_session_id] ||= SecureRandom.uuid
    end
  end
end
