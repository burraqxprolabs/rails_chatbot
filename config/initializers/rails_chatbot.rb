Rails.application.config.rails_chatbot = RailsChatbot.configuration

Rails.application.config.to_prepare do
  # Allow configuration to be set in initializers
  if Rails.application.config.rails_chatbot
    RailsChatbot.configuration.openai_api_key ||= Rails.application.config.rails_chatbot.openai_api_key
    RailsChatbot.configuration.openai_model ||= Rails.application.config.rails_chatbot.openai_model
    RailsChatbot.configuration.chatbot_title ||= Rails.application.config.rails_chatbot.chatbot_title
    RailsChatbot.configuration.current_user_proc ||= Rails.application.config.rails_chatbot.current_user_proc
    RailsChatbot.configuration.enable_knowledge_base_indexing ||= Rails.application.config.rails_chatbot.enable_knowledge_base_indexing
    RailsChatbot.configuration.indexable_models ||= Rails.application.config.rails_chatbot.indexable_models
  end
end
