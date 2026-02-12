require "rails_chatbot/version"
require "rails_chatbot/engine"

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
    attr_accessor :openai_api_key, :openai_model, :chatbot_title, :current_user_proc, :enable_knowledge_base_indexing

    def initialize
      @openai_api_key = ENV['OPENAI_API_KEY']
      @openai_model = 'gpt-4o-mini'
      @chatbot_title = 'Application Assistant'
      @enable_knowledge_base_indexing = true
      @current_user_proc = nil
    end
  end
end
