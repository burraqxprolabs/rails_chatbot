module RailsChatbot
  class Railtie < Rails::Railtie
    railtie_name :rails_chatbot

    rake_tasks do
      load "tasks/rails_chatbot_tasks.rake"
    end

    initializer "rails_chatbot.configure" do
      Rails.application.configure do
        # Auto-index knowledge base after models are loaded
        config.after_initialize do
          if RailsChatbot.configuration.enable_knowledge_base_indexing && 
             defined?(Rails::Server) && 
             !Rails.env.test?
            RailsChatbot::KnowledgeIndexer.index_all_models
          end
        end
      end
    end
  end
end
