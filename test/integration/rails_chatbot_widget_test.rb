require "test_helper"

class RailsChatbotWidgetTest < ActionDispatch::IntegrationTest
  def setup
    RailsChatbot.configure do |config|
      config.openai_api_key = 'test-key'
      config.chatbot_title = 'Test Assistant'
      config.enable_widget = true
    end
  end

  test "chatbot widget is included in layout when enabled" do
    get '/'
    
    assert_response :success
    assert_select 'div#chatbot-toggle', count: 1
    assert_select 'svg', count: 1
  end

  test "chatbot widget shows correct title" do
    get '/chatbot'
    
    assert_response :success
    assert_select '.chatbot-title', text: 'Test Assistant'
  end

  test "chatbot routes are accessible" do
    get '/chatbot'
    assert_response :success
    
    get '/chatbot/search?q=test'
    assert_response :success
    
    post '/chatbot/conversations', params: { conversation: { title: 'Test Chat' } }
    assert_response :success
  end

  test "knowledge base indexing works" do
    # Add test knowledge
    RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
      title: "Test Entry",
      content: "This is a test knowledge entry",
      source_type: "test"
    )
    
    assert_equal 1, RailsChatbot::KnowledgeBase.where(source_type: "test").count
  end

  test "application content service finds default responses" do
    results = RailsChatbot::ApplicationContentService.search_application_content("What services do you offer?")
    
    assert_equal 1, results.length
    assert_equal "Services", results.first[:title]
    assert_includes results.first[:content], "web-based applications using Ruby on Rails"
  end

  test "chat service processes messages correctly" do
    conversation = RailsChatbot::Conversation.create!(title: "Test Chat")
    service = RailsChatbot::ChatService.new(conversation: conversation)
    
    result = service.process_message("Hello")
    
    assert result.key?(:response)
    assert result.key?(:knowledge_sources)
    assert_not_nil result[:response]
  end

  test "configuration options are accessible" do
    assert RailsChatbot.configuration.enable_widget
    assert_equal 'Test Assistant', RailsChatbot.configuration.chatbot_title
    assert_equal 'test-key', RailsChatbot.configuration.openai_api_key
  end

  test "default responses are properly configured" do
    responses = RailsChatbot.configuration.default_responses
    
    assert responses.key?(:greeting)
    assert responses.key?(:services)
    assert responses.key?(:no_results)
    assert responses.key?(:error)
  end
end
