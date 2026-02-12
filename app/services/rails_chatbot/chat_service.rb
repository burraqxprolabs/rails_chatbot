module RailsChatbot
  class ChatService
    attr_reader :conversation, :llm_service

    def initialize(conversation:, api_key: nil)
      @conversation = conversation
      @llm_service = LlmService.new(api_key: api_key)
    end

    def process_message(user_message)
      # Retrieve relevant knowledge
      knowledge_service = KnowledgeRetrievalService.new(query: user_message)
      context = knowledge_service.format_context

      # Get conversation history
      messages = conversation.conversation_history

      # Add the new user message
      conversation.add_user_message(user_message)

      # Generate response
      response = llm_service.chat(
        messages: messages,
        context: context
      )

      # Save assistant response
      conversation.add_assistant_message(
        response,
        metadata: {
          knowledge_results: knowledge_service.retrieve.map { |r| r.slice(:title, :source_type, :source_id) }
        }
      )

      {
        response: response,
        knowledge_sources: knowledge_service.retrieve
      }
    end
  end
end
