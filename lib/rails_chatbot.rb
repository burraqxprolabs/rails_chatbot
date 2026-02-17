require "rails_chatbot/version"
require "rails_chatbot/engine"
require "rails_chatbot/railtie"
require "rails_chatbot/knowledge_indexer"

module RailsChatbot
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
    end
  end

  class Configuration
    attr_accessor :openai_api_key, :openai_model, :chatbot_title, :current_user_proc, :enable_knowledge_base_indexing, :indexable_models, :enable_widget, :default_responses

    def initialize
      @openai_api_key = ENV['OPENAI_API_KEY']
      @openai_model = 'gpt-4o-mini'
      @chatbot_title = 'Application Assistant'
      @enable_knowledge_base_indexing = true
      @current_user_proc = nil
      @indexable_models = nil # Array of model classes to index
      @enable_widget = true # Enable floating widget
      @default_responses = {
        greeting: "Hello! I'm your application assistant. How can I help you today?",
        services: "We are working on web-based applications using Ruby on Rails.",
        no_results: "I don't have specific information about that, but I'm here to help with general questions about our services.",
        error: "Sorry, I encountered an error. Please try again or contact support."
      }
    end
  end
end
