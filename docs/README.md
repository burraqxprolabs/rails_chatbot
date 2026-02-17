# RailsChatbot Documentation

Welcome to the RailsChatbot documentation. This comprehensive guide will help you integrate and customize the AI-powered chatbot system in your Rails application.

## 📚 Table of Contents

- [Getting Started](#getting-started)
- [API Reference](#api-reference)
- [Configuration](#configuration)
- [Models](#models)
- [Services](#services)
- [Controllers](#controllers)
- [Advanced Topics](#advanced-topics)
- [Troubleshooting](#troubleshooting)

---

## Getting Started

### Installation

Add RailsChatbot to your Gemfile:

```ruby
gem "rails_chatbot"
```

Run the installation generator:

```bash
rails generate rails_chatbot:install
```

This will:
- Create the initializer file
- Copy migration files
- Set up basic configuration

### Quick Setup

1. **Configure OpenAI API Key**

```ruby
# config/initializers/rails_chatbot.rb
RailsChatbot.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY']
  config.openai_model = 'gpt-4o-mini'
  config.chatbot_title = 'My App Assistant'
end
```

2. **Run Migrations**

```bash
rails rails_chatbot:install:migrations
rails db:migrate
```

3. **Mount the Engine**

```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount RailsChatbot::Engine => "/chatbot"
end
```

4. **Start Using**

Visit `http://localhost:3000/chatbot` to see your chatbot in action!

---

## API Reference

### Main Module

#### `RailsChatbot.configure`

Configure the chatbot system.

```ruby
RailsChatbot.configure do |config|
  config.openai_api_key = 'your-api-key'
  config.openai_model = 'gpt-4o-mini'
  config.chatbot_title = 'Support Assistant'
  config.current_user_proc = proc { |controller| controller.current_user }
  config.indexable_models = [User, Product, Order]
end
```

#### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `openai_api_key` | String | `ENV['OPENAI_API_KEY']` | OpenAI API key |
| `openai_model` | String | `'gpt-4o-mini'` | OpenAI model to use |
| `chatbot_title` | String | `'Application Assistant'` | Display title for chatbot |
| `current_user_proc` | Proc | `nil` | Proc to get current user |
| `enable_knowledge_base_indexing` | Boolean | `true` | Enable automatic model indexing |
| `indexable_models` | Array | `nil` | Custom models to index |

---

## Models

### Conversation

Represents a chat conversation session.

```ruby
conversation = RailsChatbot::Conversation.create!(
  user_id: current_user&.id,
  title: "Support Chat"
)

# Add messages
conversation.add_user_message("Hello, I need help")
conversation.add_assistant_message("How can I help you today?")
```

#### Attributes

- `id` - Unique identifier
- `user_id` - Associated user (optional)
- `title` - Conversation title
- `created_at`, `updated_at` - Timestamps

#### Methods

- `add_user_message(content)` - Add user message
- `add_assistant_message(content, metadata: {})` - Add assistant response
- `conversation_history` - Get formatted message history

### Message

Individual messages within conversations.

```ruby
message = RailsChatbot::Message.create!(
  conversation: conversation,
  role: 'user',
  content: 'Hello there'
)
```

#### Attributes

- `role` - `'user'` or `'assistant'`
- `content` - Message content
- `metadata` - Additional data (JSON)
- `conversation_id` - Associated conversation

### KnowledgeBase

Stores indexed knowledge for the chatbot.

```ruby
# Add custom knowledge
RailsChatbot::KnowledgeBase.create!(
  title: "Password Reset",
  content: "To reset your password, click 'Forgot Password'...",
  source_type: "help",
  source_url: "/help/password-reset"
)
```

#### Attributes

- `title` - Knowledge entry title
- `content` - Main content
- `source_type` - Type of source (`'help'`, `'model'`, `'custom'`)
- `source_id` - ID of source record
- `source_url` - URL to source

---

## Services

### ChatService

Main service for processing chat messages.

```ruby
service = RailsChatbot::ChatService.new(
  conversation: conversation,
  api_key: 'your-openai-key'
)

result = service.process_message("How do I reset my password?")
# => { response: "To reset your password...", knowledge_sources: [...] }
```

### KnowledgeRetrievalService

Retrieves relevant knowledge based on queries.

```ruby
service = RailsChatbot::KnowledgeRetrievalService.new(query: "password reset")
results = service.retrieve
context = service.format_context
```

### LlmService

Handles communication with OpenAI API.

```ruby
service = RailsChatbot::LlmService.new(api_key: 'your-key')
response = service.chat(
  messages: [{ role: 'user', content: 'Hello' }],
  context: 'Additional context here'
)
```

---

## Controllers

### ChatController

Main chat interface controller.

#### Routes

- `GET /chatbot` - Chat interface
- `GET /chatbot/search` - Search knowledge base

### ConversationsController

Manages conversation CRUD operations.

#### Routes

- `GET /chatbot/conversations` - List conversations
- `POST /chatbot/conversations` - Create conversation
- `GET /chatbot/conversations/:id` - Show conversation
- `DELETE /chatbot/conversations/:id` - Delete conversation

### MessagesController

Handles message creation and retrieval.

#### Routes

- `POST /chatbot/conversations/:id/messages` - Send message
- `GET /chatbot/conversations/:id/messages` - Get messages

---

## Advanced Topics

### Knowledge Indexing

#### Automatic Model Indexing

```ruby
# Index common models automatically
RailsChatbot::KnowledgeIndexer.index_all_models

# Index specific models
RailsChatbot::KnowledgeIndexer.index_model_class(User)
RailsChatbot::KnowledgeIndexer.index_model_class(Product)
```

#### Custom Knowledge Management

```ruby
# Add custom knowledge
RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Shipping Policy",
  content: "We ship within 3-5 business days...",
  source_type: "policy",
  source_url: "/policies/shipping"
)

# Remove knowledge
RailsChatbot::KnowledgeIndexer.remove_knowledge(
  source_type: "policy",
  source_id: 123
)
```

### Customization

#### Override Views

Create custom views in your application:

```erb
<!-- app/views/rails_chatbot/chat/index.html.erb -->
<div class="custom-chatbot">
  <h1><%= RailsChatbot.configuration.chatbot_title %></h1>
  <!-- Your custom chat interface -->
</div>
```

#### Custom Styles

```css
/* app/assets/stylesheets/rails_chatbot/custom.css */
.chatbot-container {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
}

.chat-message {
  padding: 12px 16px;
  margin: 8px 0;
  border-radius: 8px;
}
```

#### Extend JavaScript

```javascript
// app/javascript/rails_chatbot/custom.js
document.addEventListener('DOMContentLoaded', function() {
  // Custom chatbot behavior
  const chatInput = document.querySelector('#chat-message-input');
  
  chatInput.addEventListener('keypress', function(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      // Custom submission logic
    }
  });
});
```

### Rake Tasks

```bash
# Knowledge base management
rake app:rails_chatbot:stats                    # View statistics
rake app:rails_chatbot:clear_knowledge_base     # Clear all entries
rake app:rails_chatbot:add_knowledge['Title','Content','Type']
rake app:rails_chatbot:index_all               # Index all models
rake app:rails_chatbot:index_models[User,Post] # Index specific models
```

---

## Troubleshooting

### Common Issues

#### OpenAI API Errors

**Problem**: API key errors or rate limits
**Solution**: 
- Verify your API key is valid
- Check OpenAI account credits
- Try a different model (`gpt-3.5-turbo`)

#### No Knowledge Found

**Problem**: Chatbot responds with "I don't have information"
**Solution**:
- Run `rake app:rails_chatbot:index_all`
- Add custom knowledge entries
- Check `rake app:rails_chatbot:stats`

#### Database Issues

**Problem**: Migration errors or missing tables
**Solution**:
- Ensure PostgreSQL is configured
- Run migrations: `rails db:migrate`
- Check table existence: `rails db:migrate:status`

#### Performance Issues

**Problem**: Slow response times
**Solution**:
- Optimize knowledge base queries
- Use efficient indexing
- Consider caching frequent responses

### Debug Mode

Enable debug logging:

```ruby
# config/initializers/rails_chatbot.rb
RailsChatbot.configure do |config|
  # ... other config
  Rails.logger.level = :debug
end
```

### Testing Your Setup

```bash
# Test basic functionality
curl -X POST "http://localhost:3000/chatbot/conversations" \
  -H "Content-Type: application/json" \
  -d '{}'

# Test search
curl "http://localhost:3000/chatbot/search?q=user"

# Check stats
rake app:rails_chatbot:stats
```

---

## Support

- 📖 [GitHub Repository](https://github.com/yourusername/rails_chatbot)
- 🐛 [Issue Tracker](https://github.com/yourusername/rails_chatbot/issues)
- 💬 [Discussions](https://github.com/yourusername/rails_chatbot/discussions)
- 📧 [Email Support](mailto:support@example.com)
