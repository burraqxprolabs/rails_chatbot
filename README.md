# RailsChatbot

A powerful Rails engine gem that provides an intelligent chatbot system with knowledge base integration for your Ruby on Rails application. The chatbot can answer questions about your application by indexing your models and content.

## Features

- 🤖 **AI-Powered Chatbot**: Uses OpenAI's GPT models to provide intelligent responses
- 📚 **Knowledge Base**: Automatically indexes your application models and content
- 🔍 **Semantic Search**: Uses PostgreSQL full-text search to find relevant information
- 💬 **Conversation Management**: Maintains conversation history and context
- 🎨 **Beautiful UI**: Modern, responsive chat interface
- 🔌 **Easy Integration**: Simple setup as a Rails engine

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rails_chatbot"
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install rails_chatbot
```

## Setup

### 1. Install and Run Migrations

```bash
rails rails_chatbot:install:migrations
rails db:migrate
```

### 2. Configure the Gem

Create an initializer file `config/initializers/rails_chatbot.rb`:

```ruby
RailsChatbot.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY'] # or set directly
  config.openai_model = 'gpt-4o-mini' # or 'gpt-4', 'gpt-3.5-turbo', etc.
  config.chatbot_title = 'My Application Assistant'
  
  # Optional: Define how to get current user
  config.current_user_proc = proc { |controller| controller.current_user }
end
```

### 3. Mount the Engine

In your `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount RailsChatbot::Engine => "/chatbot"
  
  # Your other routes...
end
```

### 4. Set Environment Variable

Add your OpenAI API key to your environment:

```bash
export OPENAI_API_KEY=your_api_key_here
```

Or add it to your `.env` file if you're using dotenv.

### 5. Index Your Models

Index your application models into the knowledge base:

```bash
# Index specific models
rake rails_chatbot:index_models[User,Post,Comment]

# Index all ActiveRecord models
rake rails_chatbot:index_all
```

## Usage

### Accessing the Chatbot

Once mounted, visit `/chatbot` in your application to access the chat interface.

### Indexing Models

The gem can automatically index your ActiveRecord models. By default, it indexes the `name`, `description`, and `content` fields. You can customize this:

```ruby
# In your model or initializer
RailsChatbot::KnowledgeBase.index_model(User, fields: [:name, :email, :bio])
```

### Manual Knowledge Base Entries

You can also manually add entries to the knowledge base:

```ruby
RailsChatbot::KnowledgeBase.create!(
  title: "How to Use Feature X",
  content: "Feature X allows you to...",
  source_type: "Documentation",
  source_id: "feature-x",
  source_url: "/docs/feature-x"
)
```

### Using the Chat API

You can also use the chatbot programmatically:

```ruby
conversation = RailsChatbot::Conversation.create!(session_id: "user_123")
chat_service = RailsChatbot::ChatService.new(conversation: conversation)
result = chat_service.process_message("What is a User model?")
puts result[:response]
```

### Customizing the Chatbot

#### Custom System Prompt

You can customize the system prompt by modifying the `LlmService` or extending it:

```ruby
# In an initializer
module RailsChatbot
  class LlmService
    private

    def build_system_message(context)
      # Your custom prompt
    end
  end
end
```

#### Custom Knowledge Retrieval

Extend the `KnowledgeRetrievalService` to customize how knowledge is retrieved:

```ruby
module RailsChatbot
  class KnowledgeRetrievalService
    def retrieve
      # Your custom retrieval logic
    end
  end
end
```

## Configuration Options

| Option | Description | Default |
|--------|-------------|---------|
| `openai_api_key` | Your OpenAI API key | `ENV['OPENAI_API_KEY']` |
| `openai_model` | OpenAI model to use | `'gpt-4o-mini'` |
| `chatbot_title` | Title displayed in chat UI | `'Application Assistant'` |
| `current_user_proc` | Proc to get current user | `nil` |
| `enable_knowledge_base_indexing` | Enable auto-indexing | `true` |
| `indexable_models` | Array of model classes to index | `nil` (auto-detect common models) |

## Advanced Configuration

### Custom Model Indexing

You can specify exactly which models to index:

```ruby
RailsChatbot.configure do |config|
  config.indexable_models = [User, Product, Article, Category]
end
```

### Custom Knowledge Entries

Add custom documentation or help content:

```ruby
# Using the KnowledgeIndexer
RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "API Authentication",
  content: "To authenticate with our API, include your API key in the Authorization header...",
  source_type: "documentation",
  source_url: "/docs/authentication"
)

# Or directly create entries
RailsChatbot::KnowledgeBase.create!(
  title: "How to Reset Password",
  content: "Click the 'Forgot Password' link on the login page...",
  source_type: "help"
)
```

### Knowledge Base Management

```bash
# Add custom knowledge via rake task
rake rails_chatbot:add_knowledge['Feature Guide','Use the feature by...','guide']

# View knowledge base statistics
rake rails_chatbot:stats

# Clear all knowledge base entries
rake rails_chatbot:clear_knowledge_base
```

## Database Schema

The gem creates three main tables:

- `rails_chatbot_conversations`: Stores conversation sessions
- `rails_chatbot_messages`: Stores individual messages
- `rails_chatbot_knowledge_bases`: Stores indexed knowledge

## Rake Tasks

- `rake rails_chatbot:index_models[Model1,Model2]` - Index specific models
- `rake rails_chatbot:index_all` - Index all ActiveRecord models
- `rake rails_chatbot:clear_knowledge_base` - Clear all knowledge base entries
- `rake rails_chatbot:add_knowledge['Title','Content','Type']` - Add custom knowledge
- `rake rails_chatbot:stats` - Show knowledge base statistics

## API Endpoints

The gem provides the following REST API endpoints:

- `GET /chatbot` - Chat interface
- `POST /chatbot/conversations` - Create new conversation
- `GET /chatbot/conversations` - List conversations
- `GET /chatbot/conversations/:id` - Get conversation details
- `DELETE /chatbot/conversations/:id` - Delete conversation
- `POST /chatbot/conversations/:id/messages` - Send message to conversation
- `POST /chatbot/messages` - Send message (creates conversation if needed)
- `GET /chatbot/search?q=query` - Search knowledge base

## Example Integration

Here's a complete example of how to integrate the chatbot into a Rails application:

### 1. Gemfile
```ruby
gem 'rails_chatbot'
```

### 2. Routes
```ruby
Rails.application.routes.draw do
  mount RailsChatbot::Engine => "/support"
  
  # Your existing routes...
  root 'pages#home'
end
```

### 3. Initializer (config/initializers/rails_chatbot.rb)
```ruby
RailsChatbot.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY']
  config.openai_model = 'gpt-4o-mini'
  config.chatbot_title = 'App Support Assistant'
  config.current_user_proc = proc { |controller| controller.current_user }
  config.indexable_models = [User, Product, Order, HelpArticle]
end
```

### 4. Add to Layout
```erb
<!-- app/views/layouts/application.html.erb -->
<%= link_to 'Chat Support', '/support', class: 'btn btn-primary' %>
```

### 5. Seed Knowledge Base
```ruby
# db/seeds.rb
RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Account Settings",
  content: "You can update your profile by clicking on Settings in the navigation menu...",
  source_type: "help"
)

RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Password Reset",
  content: "To reset your password, click 'Forgot Password' on the login page...",
  source_type: "help"
)
```

## Requirements

- Ruby on Rails 8.0.4 or higher
- PostgreSQL (for full-text search)
- OpenAI API key

## Dependencies

- `rails` (>= 8.0.4)
- `ruby-openai` (~> 7.0)
- `pg_search` (~> 2.3)

## Development

After checking out the repo, run:

```bash
bin/setup
```

To run tests:

```bash
rake test
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/rails_chatbot.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
# rails_chatbot
