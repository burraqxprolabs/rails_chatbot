require "test_helper"
require 'benchmark'

class RailsChatbotPerformanceTest < ActiveSupport::TestCase
  def setup
    # Create test knowledge entries
    10.times do |i|
      RailsChatbot::KnowledgeBase.create!(
        title: "Test Entry #{i}",
        content: "This is test content for entry #{i}",
        source_type: "test"
      )
    end
  end

  test "knowledge search performance" do
    search_time = Benchmark.measure do
      100.times do
        RailsChatbot::ApplicationContentService.search_application_content("test query")
      end
    end
    
    # Should complete 100 searches in under 1 second
    assert search_time.real < 1.0, "Knowledge search too slow: #{search_time.real}s"
  end

  test "conversation creation performance" do
    creation_time = Benchmark.measure do
      50.times do
        RailsChatbot::Conversation.create!(title: "Performance Test #{i}")
      end
    end
    
    # Should create 50 conversations in under 0.5 seconds
    assert creation_time.real < 0.5, "Conversation creation too slow: #{creation_time.real}s"
  end

  test "message processing performance" do
    conversation = RailsChatbot::Conversation.create!(title: "Performance Test")
    service = RailsChatbot::ChatService.new(conversation: conversation)
    
    processing_time = Benchmark.measure do
      10.times do
        service.process_message("Test message #{i}")
      end
    end
    
    # Should process 10 messages in under 2 seconds
    assert processing_time.real < 2.0, "Message processing too slow: #{processing_time.real}s"
  end

  test "widget rendering performance" do
    rendering_time = Benchmark.measure do
      10.times do |i|
        get '/'
        assert_response :success
      end
    end
    
    # Should render 10 pages in under 1 second
    assert rendering_time.real < 1.0, "Widget rendering too slow: #{rendering_time.real}s"
  end
end
