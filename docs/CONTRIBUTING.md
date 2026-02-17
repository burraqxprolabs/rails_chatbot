# Contributing to RailsChatbot

Thank you for your interest in contributing to RailsChatbot! This guide will help you get started with contributing to the project.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Code Style](#code-style)
- [Testing](#testing)
- [Documentation](#documentation)
- [Submitting Changes](#submitting-changes)
- [Community Guidelines](#community-guidelines)

## Getting Started

### Prerequisites

- Ruby 3.2 or higher
- Rails 8.0.4 or higher
- PostgreSQL 14 or higher
- Git
- OpenAI API key (for testing)

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:

```bash
git clone https://github.com/yourusername/rails_chatbot.git
cd rails_chatbot
```

3. Add the original repository as upstream:

```bash
git remote add upstream https://github.com/originalusername/rails_chatbot.git
```

## Development Setup

### Install Dependencies

```bash
# Install Ruby gems
bundle install

# Create and setup database
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:test:prepare

# Install JavaScript dependencies (if any)
npm install
```

### Environment Configuration

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your settings
OPENAI_API_KEY=your_test_api_key_here
DATABASE_URL=postgresql://localhost/rails_chatbot_development
```

### Run Test Suite

```bash
# Run all tests
bundle exec rails test

# Run specific test file
bundle exec rails test test/models/rails_chatbot/conversation_test.rb

# Run with coverage
bundle exec rails test COVERAGE=true
```

### Start Development Server

```bash
bundle exec rails server
```

Visit `http://localhost:3000/chatbot` to test the development version.

## How to Contribute

### Types of Contributions

We welcome the following types of contributions:

1. **Bug Reports** - Found a bug? Please report it!
2. **Feature Requests** - Have an idea for a new feature?
3. **Code Contributions** - Pull requests for bug fixes or new features
4. **Documentation** - Improving documentation and examples
5. **Tests** - Writing or improving test coverage

### Reporting Bugs

Before creating a bug report:

1. Check existing issues to avoid duplicates
2. Ensure you're using the latest version
3. Try to reproduce the issue in a clean environment

When creating a bug report:

- Use a descriptive title
- Provide detailed steps to reproduce
- Include your environment details (Ruby version, Rails version, OS)
- Add relevant error messages and logs
- Include screenshots if applicable

**Bug Report Template:**

```markdown
## Bug Description
Brief description of the bug

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- Ruby version:
- Rails version:
- RailsChatbot version:
- OS:
- Database:

## Error Messages
```
Paste error messages here
```

## Additional Context
Any other relevant information
```

### Feature Requests

When requesting a new feature:

1. Check existing issues and pull requests
2. Consider if the feature aligns with the project's goals
3. Provide a clear description of the feature
4. Explain the use case and why it's valuable

**Feature Request Template:**

```markdown
## Feature Description
Clear description of the proposed feature

## Use Case
Explain why this feature is needed

## Proposed Solution
How you envision the feature working

## Alternatives Considered
Other approaches you've thought about

## Additional Context
Any other relevant information
```

## Code Style

### Ruby Style Guide

We follow the [Ruby Style Guide](https://github.com/rubocop/ruby-style-guide). Key points:

- Use 2 spaces for indentation
- Use snake_case for variable and method names
- Use CamelCase for class and module names
- Use descriptive variable and method names
- Keep lines under 100 characters
- Use meaningful comments

### Rails Conventions

- Follow Rails naming conventions
- Use Rails' built-in methods when possible
- Keep controllers thin
- Put business logic in services or models
- Use strong parameters
- Follow RESTful conventions

### Code Examples

```ruby
# Good
class ChatService
  def initialize(conversation:, api_key: nil)
    @conversation = conversation
    @api_key = api_key || RailsChatbot.configuration.openai_api_key
  end

  def process_message(user_message)
    validate_message!(user_message)
    
    response = generate_response(user_message)
    save_response(response)
    
    response
  end

  private

  def validate_message!(message)
    raise ArgumentError, "Message cannot be empty" if message.blank?
  end

  def generate_response(message)
    # Implementation here
  end

  def save_response(response)
    # Implementation here
  end
end

# Bad
class chatservice
  def initialize(c, key = nil)
    @conv = c
    @key = key || RailsChatbot.configuration.openai_api_key
  end

  def process(msg)
    if msg.empty?
      raise "bad message"
    end
    
    resp = gen_resp(msg)
    save(resp)
    
    resp
  end
end
```

## Testing

### Test Coverage

We aim for high test coverage. All new features should include:

- Unit tests for models and services
- Integration tests for user flows
- Controller tests for API endpoints
- Performance tests for critical paths

### Test Structure

```ruby
# test/models/rails_chatbot/conversation_test.rb
module RailsChatbot
  class ConversationTest < ActiveSupport::TestCase
    def setup
      @conversation = Conversation.create!(title: "Test Chat")
    end

    test "should create conversation with valid attributes" do
      assert @conversation.persisted?
      assert_equal "Test Chat", @conversation.title
    end

    test "should add user message" do
      message = @conversation.add_user_message("Hello")
      
      assert message.persisted?
      assert_equal "user", message.role
      assert_equal "Hello", message.content
    end

    test "should validate title presence" do
      conversation = Conversation.new
      assert_not conversation.valid?
      assert_includes conversation.errors[:title], "can't be blank"
    end
  end
end
```

### Test Data

Use factories for test data:

```ruby
# test/factories/rails_chatbot/conversations.rb
FactoryBot.define do
  factory :rails_chatbot_conversation, class: 'RailsChatbot::Conversation' do
    title { "Test Conversation" }
    user { association :user }
    
    trait :with_messages do
      after(:create) do |conversation|
        conversation.add_user_message("Hello")
        conversation.add_assistant_message("Hi there!")
      end
    end
  end
end
```

### Mocking External Services

Mock OpenAI API in tests:

```ruby
# test/support/mock_openai.rb
class MockOpenAIClient
  def self.chat(messages:, context: nil)
    "This is a mock response for testing purposes."
  end
end

# Replace real service in tests
RailsChatbot::LlmService = MockOpenAIClient
```

## Documentation

### Code Documentation

- Document public methods with YARD comments
- Include parameter types and return values
- Add usage examples for complex methods

```ruby
# Processes a user message and generates an AI response
#
# @param user_message [String] The message from the user
# @param context [Hash, nil] Additional context for the AI
# @return [Hash] Response containing the AI message and metadata
#
# @example Process a simple message
#   service.process_message("Hello")
#   #=> { response: "Hi there!", knowledge_sources: [] }
#
# @example Process message with context
#   service.process_message("Help me", { user_type: "premium" })
#   #=> { response: "How can I assist you today?", knowledge_sources: [...] }
#
def process_message(user_message, context: nil)
  # Implementation
end
```

### README Documentation

Keep the README up to date with:
- Installation instructions
- Quick start guide
- Configuration options
- Common use cases
- Troubleshooting tips

### API Documentation

Document all public API endpoints:
- Request parameters
- Response formats
- Error codes
- Authentication requirements

## Submitting Changes

### Branch Naming

Use descriptive branch names:

- `bugfix/chat-message-persistence`
- `feature/knowledge-base-search`
- `docs/api-reference-update`
- `test/conversation-model-tests`

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
type(scope): description

[optional body]

[optional footer(s)]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Maintenance tasks

Examples:
```
feat(chat): add message threading support

Add ability to group messages into threads for better conversation organization.

Closes #123
```

```
fix(knowledge): resolve search performance issue

Optimize database queries for knowledge base search by adding proper indexes.
```

### Pull Request Process

1. **Create Pull Request**
   - Use a descriptive title
   - Link to relevant issues
   - Add appropriate labels

2. **PR Description Template**

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] All tests pass
- [ ] New tests added for new functionality
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Changelog updated (if applicable)
```

3. **Code Review**
   - Address reviewer feedback promptly
   - Be open to suggestions
   - Keep discussions constructive

4. **Merge**
   - Ensure CI passes
   - Resolve any conflicts
   - Use squash merge for clean history

## Community Guidelines

### Code of Conduct

We are committed to providing a welcoming and inclusive environment. Please:

- Be respectful and considerate
- Use inclusive language
- Focus on constructive feedback
- Help others learn and grow

### Communication

- Use GitHub issues for bug reports and feature requests
- Use discussions for general questions
- Be patient with maintainers and contributors
- Provide helpful and detailed information

### Getting Help

- Check the documentation first
- Search existing issues and discussions
- Create a new issue with detailed information
- Join our community discussions

## Recognition

Contributors are recognized in several ways:

- Contributors section in README
- Release notes mentioning contributors
- Special contributor badges
- Invitation to core team for significant contributions

## Release Process

### Version Management

We follow Semantic Versioning:
- `MAJOR.MINOR.PATCH`
- Major: Breaking changes
- Minor: New features (backward compatible)
- Patch: Bug fixes (backward compatible)

### Release Checklist

1. Update version number
2. Update CHANGELOG.md
3. Update documentation
4. Run full test suite
5. Create release tag
6. Publish to RubyGems
7. Create GitHub release

## Additional Resources

- [Ruby Style Guide](https://github.com/rubocop/ruby-style-guide)
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
- [YARD Documentation](https://yardoc.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)

Thank you for contributing to RailsChatbot! Your contributions help make this project better for everyone.
