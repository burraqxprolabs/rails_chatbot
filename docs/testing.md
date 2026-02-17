# Testing Guide

This guide covers how to test your RailsChatbot integration and write tests for custom functionality.

## Testing Your Setup

### Manual Testing Checklist

#### Basic Functionality

- [ ] Chat interface loads at `/chatbot`
- [ ] Can send messages and receive responses
- [ ] OpenAI API integration works
- [ ] Knowledge base search returns results
- [ ] Conversations are saved properly

#### Knowledge Base

- [ ] Model indexing works: `rake app:rails_chatbot:index_all`
- [ ] Custom knowledge can be added
- [ ] Search functionality returns relevant results
- [ ] Knowledge stats display correctly

#### API Endpoints

- [ ] `GET /chatbot/conversations` - Lists conversations
- [ ] `POST /chatbot/conversations` - Creates conversation
- [ ] `POST /chatbot/conversations/:id/messages` - Sends message
- [ ] `GET /chatbot/search?q=query` - Searches knowledge

### Test Commands

```bash
# Test basic chat functionality
curl -X POST "http://localhost:3000/chatbot/conversations" \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Chat"}'

# Test message sending (replace CONVERSATION_ID)
curl -X POST "http://localhost:3000/chatbot/conversations/CONVERSATION_ID/messages" \
  -H "Content-Type: application/json" \
  -d '{"content": "Hello, how are you?"}'

# Test search functionality
curl "http://localhost:3000/chatbot/search?q=password"

# Check knowledge base stats
rake app:rails_chatbot:stats
```

## Automated Testing

### Setting Up Test Environment

```ruby
# test/test_helper.rb
ENV['RAILS_ENV'] = 'test'
require File.expand_path('../dummy/config/environment', __FILE__)
require 'rails/test_help'

# Mock OpenAI API in tests
class MockOpenAIClient
  def self.chat(messages:, context: nil)
    "This is a mock response for testing purposes."
  end
end

# Replace real service in tests
RailsChatbot::LlmService = MockOpenAIClient
```

### Model Tests

```ruby
# test/models/rails_chatbot/conversation_test.rb
module RailsChatbot
  class ConversationTest < ActiveSupport::TestCase
    def setup
      @conversation = Conversation.create!(title: "Test Chat")
    end

    test "should create conversation" do
      assert @conversation.persisted?
      assert_equal "Test Chat", @conversation.title
    end

    test "should add user message" do
      message = @conversation.add_user_message("Hello")
      
      assert message.persisted?
      assert_equal "user", message.role
      assert_equal "Hello", message.content
      assert_equal @conversation, message.conversation
    end

    test "should add assistant message" do
      message = @conversation.add_assistant_message("Hi there!")
      
      assert message.persisted?
      assert_equal "assistant", message.role
      assert_equal "Hi there!", message.content
    end

    test "should format conversation history" do
      @conversation.add_user_message("Hello")
      @conversation.add_assistant_message("Hi there!")
      
      history = @conversation.conversation_history
      
      assert_equal 2, history.length
      assert_equal "user", history.first[:role]
      assert_equal "assistant", history.last[:role]
    end
  end
end
```

```ruby
# test/models/rails_chatbot/knowledge_base_test.rb
module RailsChatbot
  class KnowledgeBaseTest < ActiveSupport::TestCase
    def setup
      @knowledge = KnowledgeBase.create!(
        title: "Test Knowledge",
        content: "This is test content for searching.",
        source_type: "test"
      )
    end

    test "should create knowledge entry" do
      assert @knowledge.persisted?
      assert_equal "Test Knowledge", @knowledge.title
      assert_equal "test", @knowledge.source_type
    end

    test "should search knowledge base" do
      results = KnowledgeBase.search("test content")
      
      assert_includes results, @knowledge
    end

    test "should index model records" do
      # Create a test model
      test_model = Class.new(ActiveRecord::Base) do
        self.table_name = 'test_records'
      end
      
      # Mock indexing
      KnowledgeBase.expects(:index_model).with(test_model, anything).returns(5)
      
      count = KnowledgeBase.index_model(test_model, fields: [:name, :description])
      assert_equal 5, count
    end
  end
end
```

### Service Tests

```ruby
# test/services/rails_chatbot/chat_service_test.rb
module RailsChatbot
  class ChatServiceTest < ActiveSupport::TestCase
    def setup
      @conversation = Conversation.create!(title: "Test Chat")
      @service = ChatService.new(conversation: @conversation)
    end

    test "should process user message" do
      result = @service.process_message("Hello")
      
      assert result.key?(:response)
      assert result.key?(:knowledge_sources)
      assert result[:response].is_a?(String)
    end

    test "should retrieve relevant knowledge" do
      # Create test knowledge
      KnowledgeBase.create!(
        title: "Password Reset",
        content: "To reset your password, click forgot password",
        source_type: "help"
      )
      
      result = @service.process_message("How do I reset my password?")
      
      assert result[:knowledge_sources].any? { |k| k.title.include?("Password") }
    end

    test "should handle empty knowledge base" do
      # Clear knowledge base
      KnowledgeBase.delete_all
      
      result = @service.process_message("Random question")
      
      assert_empty result[:knowledge_sources]
      assert_not_empty result[:response]
    end
  end
end
```

```ruby
# test/services/rails_chatbot/knowledge_retrieval_service_test.rb
module RailsChatbot
  class KnowledgeRetrievalServiceTest < ActiveSupport::TestCase
    def setup
      @knowledge1 = KnowledgeBase.create!(
        title: "User Guide",
        content: "This guide explains how to use the application",
        source_type: "documentation"
      )
      
      @knowledge2 = KnowledgeBase.create!(
        title: "API Reference",
        content: "API endpoints and parameters documentation",
        source_type: "documentation"
      )
      
      @service = KnowledgeRetrievalService.new(query: "how to use")
    end

    test "should retrieve relevant knowledge" do
      results = @service.retrieve
      
      assert_includes results, @knowledge1
    end

    test "should format context for LLM" do
      context = @service.format_context
      
      assert context.is_a?(String)
      assert context.include?("User Guide")
      assert context.include?("This guide explains")
    end

    test "should handle empty search results" do
      empty_service = KnowledgeRetrievalService.new(query: "nonexistent topic")
      results = empty_service.retrieve
      
      assert_empty results
    end
  end
end
```

### Controller Tests

```ruby
# test/controllers/rails_chatbot/conversations_controller_test.rb
module RailsChatbot
  class ConversationsControllerTest < ActionDispatch::IntegrationTest
    def setup
      @user = User.create!(email: "test@example.com", password: "password")
    end

    test "should create conversation" do
      post "/chatbot/conversations", params: { 
        conversation: { title: "New Chat" } 
      }
      
      assert_response :success
      json_response = JSON.parse(response.body)
      assert json_response['id']
      assert_equal "New Chat", json_response['title']
    end

    test "should list conversations" do
      conversation = Conversation.create!(title: "Test Chat")
      
      get "/chatbot/conversations"
      
      assert_response :success
      json_response = JSON.parse(response.body)
      assert json_response.any? { |c| c['title'] == "Test Chat" }
    end

    test "should show conversation" do
      conversation = Conversation.create!(title: "Test Chat")
      conversation.add_user_message("Hello")
      conversation.add_assistant_message("Hi there!")
      
      get "/chatbot/conversations/#{conversation.id}"
      
      assert_response :success
      json_response = JSON.parse(response.body)
      assert_equal "Test Chat", json_response['title']
      assert_equal 2, json_response['messages'].length
    end
  end
end
```

```ruby
# test/controllers/rails_chatbot/messages_controller_test.rb
module RailsChatbot
  class MessagesControllerTest < ActionDispatch::IntegrationTest
    def setup
      @conversation = Conversation.create!(title: "Test Chat")
    end

    test "should send message and receive response" do
      post "/chatbot/conversations/#{@conversation.id}/messages", 
           params: { message: { content: "Hello, how are you?" } }
      
      assert_response :success
      json_response = JSON.parse(response.body)
      
      assert json_response['message']
      assert json_response['message']['role'] == 'assistant'
      assert json_response['message']['content'].is_a?(String)
      assert json_response['knowledge_sources'].is_a?(Array)
    end

    test "should handle empty message" do
      post "/chatbot/conversations/#{@conversation.id}/messages", 
           params: { message: { content: "" } }
      
      assert_response :bad_request
    end

    test "should handle invalid conversation" do
      post "/chatbot/conversations/99999/messages", 
           params: { message: { content: "Hello" } }
      
      assert_response :not_found
    end
  end
end
```

### Integration Tests

```ruby
# test/integration/rails_chatbot/chat_flow_test.rb
module RailsChatbot
  class ChatFlowTest < ActionDispatch::IntegrationTest
    def setup
      # Add test knowledge
      KnowledgeBase.create!(
        title: "Password Reset",
        content: "Click forgot password on login page",
        source_type: "help"
      )
    end

    test "complete chat flow" do
      # Start conversation
      post "/chatbot/conversations", params: { 
        conversation: { title: "Support Chat" } 
      }
      conversation_id = JSON.parse(response.body)['id']
      
      # Send first message
      post "/chatbot/conversations/#{conversation_id}/messages",
           params: { message: { content: "I need help with my password" } }
      
      assert_response :success
      first_response = JSON.parse(response.body)
      assert first_response['message']['content'].include?("password")
      
      # Send follow-up message
      post "/chatbot/conversations/#{conversation_id}/messages",
           params: { message: { content: "Where is the forgot password link?" } }
      
      assert_response :success
      second_response = JSON.parse(response.body)
      assert second_response['message']['content'].is_a?(String)
      
      # Verify conversation history
      get "/chatbot/conversations/#{conversation_id}"
      conversation = JSON.parse(response.body)
      assert_equal 4, conversation['messages'].length # 2 user + 2 assistant
    end

    test "knowledge base search integration" do
      get "/chatbot/search?q=password"
      
      assert_response :success
      results = JSON.parse(response.body)
      assert results.any? { |r| r['title'].include?("Password") }
    end
  end
end
```

## Performance Testing

### Load Testing Script

```ruby
# test/performance/chat_load_test.rb
require 'net/http'
require 'json'
require 'concurrent'

class ChatLoadTest
  BASE_URL = 'http://localhost:3000'
  
  def initialize(concurrent_users: 10, requests_per_user: 5)
    @concurrent_users = concurrent_users
    @requests_per_user = requests_per_user
    @results = []
  end

  def run
    puts "Starting load test with #{@concurrent_users} concurrent users..."
    
    thread_pool = Concurrent::ThreadPoolExecutor.new(
      min_threads: @concurrent_users,
      max_threads: @concurrent_users
    )
    
    futures = @concurrent_users.times.map do |user_id|
      Concurrent::Future.execute(executor: thread_pool) do
        simulate_user_session(user_id)
      end
    end
    
    futures.each { |future| @results << future.value }
    
    thread_pool.shutdown
    print_results
  end

  private

  def simulate_user_session(user_id)
    user_results = []
    
    # Create conversation
    conversation = create_conversation("User #{user_id} Chat")
    return unless conversation
    
    # Send messages
    @requests_per_user.times do |i|
      start_time = Time.current
      response = send_message(conversation['id'], "Test message #{i}")
      end_time = Time.current
      
      user_results << {
        user_id: user_id,
        message_id: i,
        response_time: end_time - start_time,
        success: response&.code == '200'
      }
    end
    
    user_results
  end

  def create_conversation(title)
    uri = URI("#{BASE_URL}/chatbot/conversations")
    response = Net::HTTP.post(uri, 
      { conversation: { title: title } }.to_json,
      'Content-Type' => 'application/json'
    )
    
    response.code == '200' ? JSON.parse(response.body) : nil
  end

  def send_message(conversation_id, content)
    uri = URI("#{BASE_URL}/chatbot/conversations/#{conversation_id}/messages")
    response = Net::HTTP.post(uri,
      { message: { content: content } }.to_json,
      'Content-Type' => 'application/json'
    )
    
    response
  end

  def print_results
    all_requests = @results.flatten
    successful_requests = all_requests.select { |r| r[:success] }
    response_times = successful_requests.map { |r| r[:response_time] }
    
    puts "\n=== Load Test Results ==="
    puts "Total requests: #{all_requests.length}"
    puts "Successful requests: #{successful_requests.length}"
    puts "Success rate: #{(successful_requests.length.to_f / all_requests.length * 100).round(2)}%"
    puts "Average response time: #{(response_times.sum / response_times.length * 1000).round(2)}ms"
    puts "Min response time: #{(response_times.min * 1000).round(2)}ms"
    puts "Max response time: #{(response_times.max * 1000).round(2)}ms"
  end
end

# Run the test
if __FILE__ == $0
  test = ChatLoadTest.new(concurrent_users: 5, requests_per_user: 3)
  test.run
end
```

## Test Data Management

### Test Seeds

```ruby
# test/seeds/rails_chatbot_seeds.rb
# Create test knowledge base
RailsChatbot::KnowledgeBase.create!([
  {
    title: "User Registration",
    content: "Users can register by providing email and creating a password",
    source_type: "help"
  },
  {
    title: "Password Reset",
    content: "Click the forgot password link on the login page",
    source_type: "help"
  },
  {
    title: "API Documentation",
    content: "RESTful API with JSON responses, authentication via API keys",
    source_type: "documentation"
  }
])

# Create test conversations
5.times do |i|
  conversation = RailsChatbot::Conversation.create!(
    title: "Test Conversation #{i + 1}"
  )
  
  conversation.add_user_message("Hello, I need help")
  conversation.add_assistant_message("How can I assist you today?")
end
```

### Database Cleaner Setup

```ruby
# test/support/database_cleaner.rb
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

class ActiveSupport::TestCase
  setup { DatabaseCleaner.start }
  teardown { DatabaseCleaner.clean }
end
```

## Continuous Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Test RailsChatbot

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: '3.2'
        bundler-cache: true
    
    - name: Setup Database
      env:
        DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
      run: |
        bundle exec rails db:create
        bundle exec rails db:migrate
        
    - name: Run Tests
      env:
        OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
        DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
      run: |
        bundle exec rails test
        
    - name: Run Performance Tests
      env:
        DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
      run: |
        bundle exec ruby test/performance/chat_load_test.rb
```

This comprehensive testing guide ensures your RailsChatbot integration is robust and reliable. Regular testing helps catch issues early and maintains quality as your application grows.
