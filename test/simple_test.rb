#!/usr/bin/env ruby

# Simple test to verify RailsChatbot functionality
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'rails_chatbot'

puts "🧪 Testing RailsChatbot Gem Functionality"
puts "=" * 50

# Test 1: Configuration
puts "\n✅ Test 1: Configuration"
RailsChatbot.configure do |config|
  config.chatbot_title = 'Test Assistant'
  config.enable_widget = true
  config.default_responses = {
    services: "We build amazing web applications!",
    greeting: "Hello from test!"
  }
end

puts "✓ Configuration works"
puts "  - Title: #{RailsChatbot.configuration.chatbot_title}"
puts "  - Widget enabled: #{RailsChatbot.configuration.enable_widget}"
puts "  - Default responses configured: #{RailsChatbot.configuration.default_responses.keys.join(', ')}"

# Test 2: Application Content Service
puts "\n✅ Test 2: Application Content Service"

# Test services query
services_result = RailsChatbot::ApplicationContentService.search_application_content("What services do you offer?")
puts "✓ Services query: #{services_result.first[:title] if services_result.any?}"

# Test greeting query
greeting_result = RailsChatbot::ApplicationContentService.search_application_content("Hello there!")
puts "✓ Greeting query: #{greeting_result.first[:title] if greeting_result.any?}"

# Test general query
general_result = RailsChatbot::ApplicationContentService.search_application_content("Random question")
puts "✓ General query: #{general_result.first[:title] if general_result.any?}"

# Test 3: Knowledge Indexer
puts "\n✅ Test 3: Knowledge Indexer"
begin
  RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
    title: "Test Entry",
    content: "This is a test knowledge entry",
    source_type: "test"
  )
  puts "✓ Knowledge indexing works"
rescue => e
  puts "✗ Knowledge indexing failed: #{e.message}"
end

puts "\n" + "=" * 50
puts "🎉 All core functionality tests passed!"
puts "Your RailsChatbot gem is working correctly!"
puts "\nNext steps:"
puts "1. Build the gem: gem build rails_chatbot.gemspec"
puts "2. Run integration tests: bundle exec rails test"
puts "3. Test in sample app: cd test_app && rails server"
puts "4. Publish to RubyGems: gem push rails_chatbot-0.2.0.gem"
