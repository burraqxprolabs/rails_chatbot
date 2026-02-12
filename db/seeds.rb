# This file contains sample data for the RailsChatbot knowledge base
# Run with: rails db:seed

RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Getting Started with RailsChatbot",
  content: <<~CONTENT
    RailsChatbot is a powerful AI-powered chatbot system for Rails applications.
    
    To get started:
    1. Install the gem and run migrations
    2. Configure your OpenAI API key
    3. Mount the engine in your routes
    4. Index your models or add custom knowledge
    
    The chatbot will then be able to answer questions about your application.
  CONTENT,
  source_type: "documentation",
  source_url: "/docs/getting-started"
)

RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "API Configuration",
  content: <<~CONTENT
    Configure RailsChatbot in config/initializers/rails_chatbot.rb:
    
    RailsChatbot.configure do |config|
      config.openai_api_key = ENV['OPENAI_API_KEY']
      config.openai_model = 'gpt-4o-mini'
      config.chatbot_title = 'Your Assistant'
    end
    
    Make sure to set your OPENAI_API_KEY environment variable.
  CONTENT,
  source_type: "configuration",
  source_url: "/docs/configuration"
)

RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Knowledge Base Management",
  content: <<~CONTENT
    You can manage the knowledge base using these rake tasks:
    
    - rake rails_chatbot:index_all - Index all models
    - rake rails_chatbot:index_models[User,Post] - Index specific models
    - rake rails_chatbot:add_knowledge['Title','Content'] - Add custom knowledge
    - rake rails_chatbot:clear_knowledge_base - Clear all entries
    - rake rails_chatbot:stats - View statistics
    
    The knowledge base uses PostgreSQL full-text search for fast retrieval.
  CONTENT,
  source_type: "management",
  source_url: "/docs/knowledge-base"
)

RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Troubleshooting Common Issues",
  content: <<~CONTENT
    Common issues and solutions:
    
    1. OpenAI API errors: Check your API key and model selection
    2. Search not working: Ensure PostgreSQL is properly configured
    3. No knowledge found: Run rake rails_chatbot:index_all to populate the base
    4. Routing errors: Verify the engine is mounted correctly in routes.rb
    5. Permission errors: Check database permissions for the chatbot tables
  CONTENT,
  source_type: "troubleshooting",
  source_url: "/docs/troubleshooting"
)

RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Customizing the Chat Interface",
  content: <<~CONTENT
    You can customize the chat interface by:
    
    1. Overriding views in your app/views/rails_chatbot/
    2. Modifying CSS styles in app/assets/stylesheets/rails_chatbot/
    3. Extending JavaScript functionality in app/javascript/rails_chatbot/
    4. Customizing the system prompt in LlmService
    
    The interface is built with vanilla JavaScript and can be easily customized.
  CONTENT,
  source_type: "customization",
  source_url: "/docs/customization"
)

puts "✓ RailsChatbot sample knowledge base seeded successfully!"
