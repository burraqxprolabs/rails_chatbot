RailsChatbot.configure do |config|
  # Set your OpenAI API key
  config.openai_api_key = ENV['OPENAI_API_KEY']
  
  # Choose the model (gpt-4o-mini, gpt-4, gpt-3.5-turbo, etc.)
  config.openai_model = 'gpt-4o-mini'
  
  # Customize the chatbot title
  config.chatbot_title = 'Application Assistant'
  
  # Optional: Define how to get current user (uncomment and customize)
  # config.current_user_proc = proc { |controller| controller.current_user }
end
