# Examples and Use Cases

This document provides practical examples and common use cases for RailsChatbot.

## E-commerce Store Example

### Setup for E-commerce

```ruby
# config/initializers/rails_chatbot.rb
RailsChatbot.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY']
  config.chatbot_title = 'Shopping Assistant'
  config.indexable_models = [Product, Category, Brand, Review]
  config.current_user_proc = proc { |controller| controller.current_user }
end
```

### Index Products

```bash
# Index all products with their details
rake app:rails_chatbot:index_models[Product]

# Add product-specific knowledge
RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Shipping Policy",
  content: "We offer free shipping on orders over $50. Standard shipping takes 3-5 business days. Express shipping (1-2 days) is available for $15.",
  source_type: "policy",
  source_url: "/policies/shipping"
)

RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Return Policy",
  content: "You can return items within 30 days of purchase. Items must be unused and in original packaging. Refunds are processed within 5-7 business days.",
  source_type: "policy",
  source_url: "/policies/returns"
)
```

### Customer Support Scenarios

```ruby
# Add common customer service knowledge
RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Track Your Order",
  content: "To track your order, go to My Account > Order History. Click on the order number to see real-time tracking information. You'll also receive email updates at each shipping milestone.",
  source_type: "help",
  source_url: "/help/order-tracking"
)

RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Payment Methods",
  content: "We accept Visa, Mastercard, American Express, PayPal, and Apple Pay. All payments are processed securely through our PCI-compliant payment gateway.",
  source_type: "help",
  source_url: "/help/payment"
)
```

### Example Customer Interactions

**Customer:** "What's your return policy for electronics?"

**Chatbot Response:** "For electronics, you can return items within 30 days of purchase. Items must be unused and in original packaging with all accessories included. Refunds are processed within 5-7 business days. Some restrictions may apply to opened software or customized items."

**Customer:** "Do you have any blue t-shirts in size large?"

**Chatbot Response:** "Let me check our inventory for you. Based on our product catalog, we have several blue t-shirts available in size large from different brands including Nike, Adidas, and our store brand. Prices range from $19.99 to $39.99. Would you like me to show you specific options?"

---

## SaaS Application Example

### Setup for SaaS

```ruby
# config/initializers/rails_chatbot.rb
RailsChatbot.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY']
  config.chatbot_title = 'Product Support'
  config.indexable_models = [User, Feature, Subscription, Plan, Documentation]
  config.current_user_proc = proc { |controller| controller.current_user }
end
```

### Feature Documentation

```ruby
# Add feature-specific knowledge
RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Dashboard Overview",
  content: "The main dashboard shows your key metrics, recent activity, and quick actions. The top section displays real-time analytics, the middle shows recent transactions, and the bottom provides quick access to common tasks.",
  source_type: "documentation",
  source_url: "/docs/dashboard"
)

RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "API Rate Limits",
  content: "Free tier: 100 requests/hour. Pro tier: 1,000 requests/hour. Enterprise: Unlimited. Rate limits reset at the beginning of each hour. Check the X-RateLimit headers in API responses for current status.",
  source_type: "documentation",
  source_url: "/docs/api/rate-limits"
)
```

### User Onboarding

```ruby
RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Getting Started Guide",
  content: "New to our platform? Start with these steps: 1) Complete your profile setup, 2) Connect your first data source, 3) Create your first project, 4) Invite team members, 5) Explore the dashboard. Each step takes about 5 minutes.",
  source_type: "onboarding",
  source_url: "/getting-started"
)
```

### Example User Interactions

**User:** "How do I upgrade my subscription?"

**Chatbot Response:** "To upgrade your subscription, go to Settings > Billing > Change Plan. You'll see available upgrade options with prorated pricing. The upgrade takes effect immediately, and you'll be charged the difference for the current billing period."

**User:** "What are the API rate limits?"

**Chatbot Response:** "API rate limits depend on your subscription tier: Free tier allows 100 requests per hour, Pro tier allows 1,000 requests per hour, and Enterprise has unlimited requests. Rate limits reset at the beginning of each hour. You can check your current status in the X-RateLimit headers of API responses."

---

## Educational Platform Example

### Setup for Education

```ruby
# config/initializers/rails_chatbot.rb
RailsChatbot.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY']
  config.chatbot_title = 'Learning Assistant'
  config.indexable_models = [Course, Lesson, Assignment, User, Resource]
  config.current_user_proc = proc { |controller| controller.current_user }
end
```

### Course Content

```ruby
# Add course-specific knowledge
RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Submitting Assignments",
  content: "To submit an assignment: 1) Go to the course page, 2) Click on the assignment, 3) Upload your file or enter text, 4) Click 'Submit'. You can submit before the deadline and make multiple submissions - only the latest will be graded.",
  source_type: "help",
  source_url: "/help/assignments"
)

RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Grading Policy",
  content: "Grades are typically posted within 7 days of the assignment deadline. You can view your grades in the Grades section. If you have questions about a grade, contact your instructor within 48 hours of posting.",
  source_type: "policy",
  source_url: "/policies/grading"
)
```

### Example Student Interactions

**Student:** "When is the math homework due?"

**Chatbot Response:** "Looking at your current courses, the Math 101 homework on Chapter 5 is due this Friday at 11:59 PM. You can submit it through the Assignments section in your Math course page."

**Student:** "How do I check my grades?"

**Chatbot Response:** "To check your grades, go to the Grades section in the main navigation. You'll see all your courses with current grades, individual assignment scores, and your overall GPA. Grades are typically posted within 7 days of the assignment deadline."

---

## Healthcare Portal Example

### Setup for Healthcare

```ruby
# config/initializers/rails_chatbot.rb
RailsChatbot.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY']
  config.chatbot_title = 'Patient Support'
  config.indexable_models = [Patient, Appointment, Doctor, Department, Service]
  config.current_user_proc = proc { |controller| controller.current_patient }
end
```

### Patient Services

```ruby
# Add healthcare-specific knowledge
RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Scheduling Appointments",
  content: "To schedule an appointment: 1) Log into your patient portal, 2) Click 'Schedule Appointment', 3) Select the department and doctor, 4) Choose available date/time, 5) Confirm. You can also call the appointment line at (555) 123-4567.",
  source_type: "help",
  source_url: "/help/appointments"
)

RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
  title: "Prescription Refills",
  content: "Request prescription refills through your patient portal under Medications > Refill Requests. Allow 2-3 business days for processing. For urgent refills, call your doctor's office directly.",
  source_type: "help",
  source_url: "/help/prescriptions"
)
```

### Example Patient Interactions

**Patient:** "How do I schedule a follow-up appointment?"

**Chatbot Response:** "You can schedule a follow-up appointment through your patient portal: Log in, click 'Schedule Appointment', select your doctor, choose an available time slot, and confirm. You can also call the appointment line at (555) 123-4567 during business hours (8 AM - 6 PM, Monday-Friday)."

**Patient:** "I need to refill my blood pressure medication."

**Chatbot Response:** "You can request prescription refills through your patient portal under Medications > Refill Requests. Please allow 2-3 business days for processing. If you're running low and need an urgent refill, please call your doctor's office directly at (555) 987-6543."

---

## Custom Integration Examples

### Slack Integration

```ruby
# app/services/slack_chatbot_service.rb
class SlackChatbotService
  def self.handle_slack_message(user_id, message)
    # Find or create conversation for Slack user
    conversation = RailsChatbot::Conversation.find_or_create_by(
      user_id: user_id,
      source: 'slack'
    )
    
    # Process message through RailsChatbot
    chat_service = RailsChatbot::ChatService.new(conversation: conversation)
    result = chat_service.process_message(message)
    
    # Send response back to Slack
    SlackClient.post_message(
      channel: user_id,
      text: result[:response]
    )
  end
end
```

### Email Integration

```ruby
# app/services/email_chatbot_service.rb
class EmailChatbotService
  def self.handle_email_inquiry(from_email, subject, body)
    # Find user by email
    user = User.find_by(email: from_email)
    
    # Create conversation
    conversation = RailsChatbot::Conversation.create!(
      user: user,
      title: "Email Inquiry: #{subject}",
      source: 'email'
    )
    
    # Process inquiry
    chat_service = RailsChatbot::ChatService.new(conversation: conversation)
    result = chat_service.process_message(body)
    
    # Send email response
    ChatbotMailer.inquiry_response(
      to: from_email,
      subject: "Re: #{subject}",
      response: result[:response]
    ).deliver_later
  end
end
```

### Mobile App API

```ruby
# app/controllers/api/v1/chatbot_controller.rb
class Api::V1::ChatbotController < ApplicationController
  before_action :authenticate_user!
  
  def create_conversation
    conversation = RailsChatbot::Conversation.create!(
      user: current_user,
      title: params[:title] || "Mobile Chat"
    )
    
    render json: {
      conversation_id: conversation.id,
      created_at: conversation.created_at
    }
  end
  
  def send_message
    conversation = RailsChatbot::Conversation.find(params[:conversation_id])
    
    # Ensure user owns the conversation
    return render_unauthorized unless conversation.user == current_user
    
    chat_service = RailsChatbot::ChatService.new(conversation: conversation)
    result = chat_service.process_message(params[:message])
    
    render json: {
      response: result[:response],
      knowledge_sources: result[:knowledge_sources],
      timestamp: Time.current
    }
  end
end
```

---

## Advanced Customization

### Custom Response Formatting

```ruby
# app/services/custom_chat_service.rb
class CustomChatService < RailsChatbot::ChatService
  def process_message(user_message)
    result = super(user_message)
    
    # Add custom formatting
    formatted_response = format_response(result[:response])
    
    {
      response: formatted_response,
      knowledge_sources: result[:knowledge_sources],
      suggestions: generate_suggestions(user_message),
      related_topics: find_related_topics(user_message)
    }
  end
  
  private
  
  def format_response(response)
    # Add markdown formatting, emojis, etc.
    response.gsub(/\*\*(.*?)\*\*/, '<strong>\1</strong>')
  end
  
  def generate_suggestions(message)
    # Generate follow-up questions based on context
    case message.downcase
    when /password/
      ["How do I change my password?", "I forgot my password", "Password requirements"]
    when /shipping/
      ["Track my order", "Shipping costs", "Delivery time"]
    else
      ["Tell me more", "How does this work?", "Contact support"]
    end
  end
end
```

### Multi-language Support

```ruby
# app/services/multilingual_chat_service.rb
class MultilingualChatService < RailsChatbot::ChatService
  def process_message(user_message)
    # Detect language
    detected_language = detect_language(user_message)
    
    # Process in original language
    result = super(user_message)
    
    # Translate response if needed
    if detected_language != :en
      result[:response] = translate_text(result[:response], detected_language)
    end
    
    result
  end
  
  private
  
  def detect_language(text)
    # Simple language detection or use a service
    text.match(/[а-яё]/i) ? :ru : :en
  end
  
  def translate_text(text, target_language)
    # Use translation service
    GoogleTranslate.translate(text, to: target_language)
  end
end
```

These examples show how RailsChatbot can be adapted for various industries and use cases. The key is to provide relevant knowledge base content and customize the configuration for your specific needs.
