require "test_helper"

class RailsChatbotApplicationContentServiceTest < ActiveSupport::TestCase
  def setup
    RailsChatbot.configure do |config|
      config.default_responses = {
        services: "We build amazing web applications!",
        greeting: "Hello from test!",
        no_results: "I don't have specific information about that."
      }
    end
  end

  test "find_default_response returns services response for services query" do
    result = RailsChatbot::ApplicationContentService.send(:find_default_response, "What services do you offer?")
    
    assert_equal "Services", result[:title]
    assert_equal "We build amazing web applications!", result[:content]
    assert_equal "default", result[:source_type]
  end

  test "find_default_response returns greeting response for hello query" do
    result = RailsChatbot::ApplicationContentService.send(:find_default_response, "Hello there!")
    
    assert_equal "Greeting", result[:title]
    assert_equal "Hello from test!", result[:content]
    assert_equal "default", result[:source_type]
  end

  test "find_default_response_returns_general_response_for_other_queries" do
    result = RailsChatbot::ApplicationContentService.send(:find_default_response, "Random question")
    
    puts "DEBUG: result = #{result.inspect}"
    
    assert_equal "General Response", result[:title]
    assert_not_nil result[:content], "Content should not be nil"
    assert_equal "default", result[:source_type]
  end

  test "extract_summary truncates long content" do
    long_content = "This is a very long content that should be truncated because it exceeds the maximum length limit for summaries in the knowledge base indexing process."
    
    summary = RailsChatbot::ApplicationContentService.send(:extract_summary, long_content)
    
    assert summary.length <= 500
  end

  test "extract_routes_info finds resources routes" do
    routes_content = "resources :users\nresources :posts\nget '/about', to: 'pages#about'"
    
    routes_info = RailsChatbot::ApplicationContentService.send(:extract_routes_info, routes_content)
    
    assert_includes routes_info, "users"
    assert_includes routes_info, "posts"
  end

  test "add_knowledge_entry creates new entry" do
    initial_count = RailsChatbot::KnowledgeBase.count
    
    RailsChatbot::ApplicationContentService.send(:add_knowledge_entry,
      title: "Test Entry",
      content: "Test content",
      source_type: "test",
      source_url: "/test"
    )
    
    assert_equal initial_count + 1, RailsChatbot::KnowledgeBase.count
  end

  test "add_knowledge_entry updates existing entry" do
    # Create initial entry
    RailsChatbot::ApplicationContentService.send(:add_knowledge_entry,
      title: "Test Entry",
      content: "Original content",
      source_type: "test",
      source_url: "/test"
    )
    
    initial_count = RailsChatbot::KnowledgeBase.count
    initial_updated_at = RailsChatbot::KnowledgeBase.last.updated_at
    
    # Wait a bit to ensure different timestamp
    sleep(0.01)
    
    # Update the same entry
    RailsChatbot::ApplicationContentService.send(:add_knowledge_entry,
      title: "Test Entry",
      content: "Updated content",
      source_type: "test",
      source_url: "/test"
    )
    
    assert_equal initial_count, RailsChatbot::KnowledgeBase.count
    updated_entry = RailsChatbot::KnowledgeBase.last
    assert_equal "Updated content", updated_entry.content
    assert updated_entry.updated_at > initial_updated_at
  end
end
