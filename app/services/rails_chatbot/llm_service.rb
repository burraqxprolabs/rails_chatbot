module RailsChatbot
  class LlmService
    attr_reader :client, :model

    def initialize(api_key: nil, model: nil)
      api_key ||= RailsChatbot.configuration.openai_api_key || ENV['OPENAI_API_KEY']
      model ||= RailsChatbot.configuration.openai_model || 'gpt-4o-mini'
      
      raise ArgumentError, "OpenAI API key is required" unless api_key
      
      @client = OpenAI::Client.new(access_token: api_key)
      @model = model
    end

    def chat(messages:, context: nil, temperature: 0.7)
      system_message = build_system_message(context)
      conversation_messages = [system_message] + messages

      response = client.chat(
        parameters: {
          model: model,
          messages: conversation_messages,
          temperature: temperature
        }
      )

      response.dig('choices', 0, 'message', 'content')
    rescue => e
      Rails.logger.error("LLM Service Error: #{e.message}")
      "I apologize, but I'm experiencing technical difficulties. Please try again later."
    end

    private

    def build_system_message(context)
      base_prompt = <<~PROMPT
        You are a helpful AI assistant integrated into a Ruby on Rails application.
        Your role is to answer questions about the application and help users navigate and understand the system.
        
        You have access to the application's knowledge base, which contains information about:
        - Models and their attributes
        - Application features and functionality
        - User guides and documentation
        - Common questions and answers
        
        When answering questions:
        1. Use the provided context from the knowledge base to give accurate answers
        2. Be concise but thorough
        3. If you don't know something, admit it rather than guessing
        4. Provide helpful examples when relevant
        5. Format your responses clearly with proper markdown when appropriate
      PROMPT

      if context.present?
        base_prompt += "\n\nRelevant Context:\n#{context}"
      end

      {
        role: 'system',
        content: base_prompt
      }
    end
  end
end
