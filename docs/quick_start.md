# Quick Start Guide

Get RailsChatbot up and running in your Rails application in 5 minutes.

## Prerequisites

- Ruby on Rails 8.0.4 or higher
- PostgreSQL database
- OpenAI API key
- Modern web browser

## Step 1: Install the Gem

Add to your `Gemfile`:

```ruby
gem "rails_chatbot"
```

Install the gem:

```bash
bundle install
```

## Step 2: Generate Initializer

Run the installation generator:

```bash
rails generate rails_chatbot:install
```

This creates:
- `config/initializers/rails_chatbot.rb`
- Migration files in `db/migrate/`

## Step 3: Configure OpenAI

Set your OpenAI API key:

```bash
export OPENAI_API_KEY=your_openai_api_key_here
```

Or add to your `.env` file:

```env
OPENAI_API_KEY=your_openai_api_key_here
```

## Step 4: Run Migrations

```bash
rails rails_chatbot:install:migrations
rails db:migrate
```

## Step 5: Mount the Engine

Add to `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount RailsChatbot::Engine => "/chatbot"
  
  # Your existing routes
end
```

## Step 6: Start Your Server

```bash
rails server
```

## Step 7: Test Your Chatbot

Visit `http://localhost:3000/chatbot` in your browser.

Try these test messages:
- "Hello, how are you?"
- "What can you help me with?"
- "Tell me about this application"

## Next Steps

### Add Custom Knowledge

```ruby
# In Rails console or a seed file
RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "User Registration",
  content: "Users can register by clicking the Sign Up button in the top navigation. They need to provide their email, create a password, and verify their email address.",
  source_type: "help"
)
```

### Index Your Models

```bash
# Index all common models
rake app:rails_chatbot:index_all

# Or index specific models
rake app:rails_chatbot:index_models[User,Product,Order]
```

### Customize the Chatbot

```ruby
# config/initializers/rails_chatbot.rb
RailsChatbot.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY']
  config.openai_model = 'gpt-4o-mini'
  config.chatbot_title = 'My App Assistant'
  config.current_user_proc = proc { |controller| controller.current_user }
  config.indexable_models = [User, Product, Order]
end
```

## Troubleshooting

### Chatbot Doesn't Respond

1. Check your OpenAI API key is valid
2. Verify you have credits in your OpenAI account
3. Check Rails logs for errors

### No Knowledge Available

1. Run `rake app:rails_chatbot:index_all`
2. Add custom knowledge entries
3. Check stats with `rake app:rails_chatbot:stats`

### Routing Issues

1. Ensure the engine is mounted in routes.rb
2. Restart your Rails server
3. Check for route conflicts

## Need Help?

- 📖 [Full Documentation](./README.md)
- 🐛 [Report Issues](https://github.com/yourusername/rails_chatbot/issues)
- 💬 [Community Discussion](https://github.com/yourusername/rails_chatbot/discussions)
