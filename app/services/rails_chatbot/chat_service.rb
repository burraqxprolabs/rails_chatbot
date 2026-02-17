module RailsChatbot
  class ChatService
    attr_reader :conversation, :llm_service

    def initialize(conversation:, api_key: nil)
      @conversation = conversation
      @llm_service = LlmService.new(api_key: api_key)
    end

    def process_message(user_message)
      # Retrieve relevant knowledge from application content
      knowledge_results = ApplicationContentService.search_application_content(user_message)
      
      # Get conversation history
      messages = conversation.conversation_history

      # Add the new user message
      conversation.add_user_message(user_message)

      # Format context from knowledge results
      context = format_knowledge_context(knowledge_results)

      # Generate response
      response = if knowledge_results.any? && knowledge_results.first[:source_type] == 'default'
        # Use default response directly
        knowledge_results.first[:content]
      else
        # Generate response using LLM with context
        llm_service.chat(
          messages: messages,
          context: context
        )
      end

      # Save assistant response
      conversation.add_assistant_message(
        response,
        metadata: {
          knowledge_results: knowledge_results.map { |r| r.slice(:title, :source_type, :source_id) }
        }
      )

      {
        response: response,
        knowledge_sources: knowledge_results
      }
    end

    private

    def format_knowledge_context(knowledge_results)
      return "" if knowledge_results.empty?
      
      context_parts = knowledge_results.map do |result|
        "#{result[:title]}: #{result[:content]}"
      end
      
      "Relevant information:\n#{context_parts.join("\n\n")}"
    end
  end
end
