# RailsChatbot

A powerful Rails engine gem that provides an intelligent chatbot system with knowledge base integration for your Ruby on Rails application. The chatbot can answer questions about your application by indexing your models and content.

## � Quick Start Guide

### Step 1: Install the Gem

Add this line to your application's Gemfile:

```ruby
gem "rails_chatbot"
```

Then execute:

```bash
$ bundle install
```

### Step 2: Run Migrations

```bash
$ rails rails_chatbot:install:migrations
$ rails db:migrate
```

### Step 3: Configure OpenAI

Create `config/initializers/rails_chatbot.rb`:

```ruby
RailsChatbot.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY'] # Required
  config.openai_model = 'gpt-4o-mini' # Optional
  config.chatbot_title = 'My App Assistant' # Optional
end
```

Set your OpenAI API key:

```bash
export OPENAI_API_KEY=your_openai_api_key_here
```

### Step 4: Mount the Engine

Add to your `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount RailsChatbot::Engine => "/chatbot"
  
  # Your other routes...
end
```

### Step 5: Enable the Widget (Optional)

To enable the floating chatbot widget, add this to your application layout:

```erb
<%# In app/views/layouts/application.html.erb %>
<%= RailsChatbot::ApplicationHelper.new.include_chatbot_widget if RailsChatbot::ApplicationHelper.new.chatbot_widget_enabled? %>
```

Or simply add to any view:

```erb
<%= include_chatbot_widget %>
```

The widget will automatically appear in the bottom-right corner of your screen.

### Step 6: Start Your Server

```bash
rails server
```

Visit `http://localhost:3000/chatbot` to see your chatbot, or look for the floating chat icon in the bottom-right corner of any page!

## 🧪 Testing Your Chatbot

### 1. Test Basic Chat
- Open `http://localhost:3000/chatbot`
- Type "Hello" and send a message
- The chatbot should respond

### 2. Add Knowledge Base Content

```bash
# Add custom knowledge
rails runner "RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: 'User Registration',
  content: 'Users can register by clicking the Sign Up button...',
  source_type: 'help'
)"
```

### 3. Test Knowledge Search
In the chat, try asking:
- "How do users register?"
- "What features are available?"
- "Tell me about user management"

### 4. Test API Endpoints

```bash
# Test search
curl "http://localhost:3000/chatbot/search?q=user"

# Test conversation creation
curl -X POST "http://localhost:3000/chatbot/conversations" \
  -H "Content-Type: application/json" \
  -d '{}'
```

### 5. Check Knowledge Base Stats

```bash
rake app:rails_chatbot:stats
```

## 📚 Advanced Usage

### Index Your Models

```bash
# Index specific models
rake app:rails_chatbot:index_models[User,Post,Product]

# Index all models
rake app:rails_chatbot:index_all
```

### Add Custom Knowledge

```ruby
# Via code
RailsChatbot::KnowledgeBase.create!(
  title: "How to Reset Password",
  content: "Click 'Forgot Password' on the login page...",
  source_type: "help"
)

# Via rake task
rake app:rails_chatbot:add_knowledge['Title','Content','Type']
```

### Customize Configuration

```ruby
RailsChatbot.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY']
  config.openai_model = 'gpt-4o-mini'
  config.chatbot_title = 'Support Assistant'
  config.current_user_proc = proc { |controller| controller.current_user }
  config.indexable_models = [User, Product, Order] # Custom models to index
end
```

## 🔧 Management Commands

```bash
# Knowledge base management
rake app:rails_chatbot:stats                    # View statistics
rake app:rails_chatbot:clear_knowledge_base     # Clear all entries
rake app:rails_chatbot:add_knowledge['Title','Content','Type'] # Add knowledge
rake app:rails_chatbot:index_all               # Index all models
rake app:rails_chatbot:index_models[User,Post] # Index specific models
```

## 🎯 Common Use Cases

### E-commerce Site
```ruby
# Index products
rake app:rails_chatbot:index_models[Product,Category]

# Add help content
RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Shipping Policy",
  content: "We ship within 3-5 business days...",
  source_type: "policy"
)
```

### SaaS Application
```ruby
# Index user models and features
rake app:rails_chatbot:index_models[User,Feature,Subscription]

# Add feature documentation
RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Dashboard Overview",
  content: "The dashboard shows your usage statistics...",
  source_type: "documentation"
)
```

## 🐛 Troubleshooting

### Common Issues

1. **OpenAI API Errors**
   - Check your API key is valid
   - Verify you have credits in your OpenAI account
   - Try a different model (gpt-3.5-turbo)

2. **No Knowledge Found**
   - Run `rake app:rails_chatbot:index_all` to populate knowledge base
   - Add custom knowledge entries
   - Check `rake app:rails_chatbot:stats` for entries

3. **Search Not Working**
   - Ensure PostgreSQL is configured
   - Check database migrations ran successfully
   - Verify knowledge base has content

4. **Routing Issues**
   - Confirm engine is mounted in routes.rb
   - Check for route conflicts with existing paths
   - Restart Rails server after route changes

### Debug Mode

```ruby
# In development, add to initializer
RailsChatbot.configure do |config|
  # ... other config
  Rails.logger.level = :debug
end
```

## 📱 API Reference

### Endpoints

- `GET /chatbot` - Chat interface
- `POST /chatbot/conversations` - Create conversation
- `GET /chatbot/conversations` - List conversations
- `POST /chatbot/conversations/:id/messages` - Send message
- `GET /chatbot/search?q=query` - Search knowledge

### Response Format

```json
{
  "message": {
    "role": "assistant",
    "content": "Here's the answer...",
    "created_at": "2026-02-12T12:00:00Z"
  },
  "knowledge_sources": [
    {
      "title": "User Guide",
      "source_type": "documentation",
      "source_url": "/docs/users"
    }
  ]
}
```

## 🎨 Customization

### Override Views

Create `app/views/rails_chatbot/chat/index.html.erb` in your app to customize the chat interface.

### Custom Styles

Add to `app/assets/stylesheets/rails_chatbot/custom.css`:

```css
.chatbot-container {
  background: your-brand-color;
  border-radius: your-preference;
}
```

### Custom JavaScript

Extend functionality in `app/javascript/rails_chatbot/custom.js`.

## � Documentation

For comprehensive documentation, visit our [Documentation Site](./docs/README.md).

### Quick Links
- 🚀 [Quick Start Guide](./docs/quick_start.md) - Get up and running in 5 minutes
- 📖 [API Reference](./docs/api_reference.md) - Complete API documentation
- 💡 [Examples & Use Cases](./docs/examples.md) - Real-world implementation examples
- 🧪 [Testing Guide](./docs/testing.md) - How to test your integration
- 🚀 [Deployment Guide](./docs/deployment.md) - Production deployment instructions
- 🤝 [Contributing](./docs/CONTRIBUTING.md) - How to contribute to the project

---

## �� Requirements

- Ruby on Rails 8.0.4 or higher
- PostgreSQL (for full-text search)
- OpenAI API key
- Modern web browser

## 📄 License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## 🤝 Support

- 📖 [Documentation](https://github.com/yourusername/rails_chatbot)
- 🐛 [Issues](https://github.com/yourusername/rails_chatbot/issues)
- 💬 [Discussions](https://github.com/yourusername/rails_chatbot/discussions)
