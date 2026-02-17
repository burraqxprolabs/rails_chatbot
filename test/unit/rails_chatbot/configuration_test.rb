require "test_helper"

class RailsChatbotConfigurationTest < ActiveSupport::TestCase
  def setup
    @config = RailsChatbot::Configuration.new
  end

  test "default configuration values are set correctly" do
    assert_equal 'gpt-4o-mini', @config.openai_model
    assert_equal 'Application Assistant', @config.chatbot_title
    assert @config.enable_knowledge_base_indexing
    assert @config.enable_widget
    assert_nil @config.current_user_proc
    assert_nil @config.indexable_models
  end

  test "default_responses are configured" do
    responses = @config.default_responses
    
    assert responses.key?(:greeting)
    assert responses.key?(:services)
    assert responses.key?(:no_results)
    assert responses.key?(:error)
    
    assert_includes responses[:services], "web-based applications using Ruby on Rails"
  end

  test "configuration can be customized" do
    @config.openai_model = 'gpt-3.5-turbo'
    @config.chatbot_title = 'Custom Assistant'
    @config.enable_widget = false
    
    assert_equal 'gpt-3.5-turbo', @config.openai_model
    assert_equal 'Custom Assistant', @config.chatbot_title
    assert_not @config.enable_widget
  end

  test "configuration accepts custom default responses" do
    custom_responses = {
      greeting: "Custom greeting!",
      services: "Custom services description"
    }
    
    @config.default_responses = custom_responses
    
    assert_equal custom_responses, @config.default_responses
  end
end
