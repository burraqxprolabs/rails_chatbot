# API Reference

This document provides detailed API reference for all RailsChatbot classes, methods, and endpoints.

## Core Classes

### RailsChatbot Module

#### `RailsChatbot.configure(&block)`

Configures the chatbot system with a block.

**Parameters:**
- `block` (Proc) - Configuration block

**Example:**
```ruby
RailsChatbot.configure do |config|
  config.openai_api_key = 'sk-...'
  config.openai_model = 'gpt-4o-mini'
end
```

#### `RailsChatbot.configuration`

Returns the current configuration object.

**Returns:** `RailsChatbot::Configuration`

---

### Configuration Class

#### Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `openai_api_key` | String | `ENV['OPENAI_API_KEY']` | OpenAI API key |
| `openai_model` | String | `'gpt-4o-mini'` | OpenAI model |
| `chatbot_title` | String | `'Application Assistant'` | Chatbot display title |
| `current_user_proc` | Proc | `nil` | User resolution proc |
| `enable_knowledge_base_indexing` | Boolean | `true` | Enable auto-indexing |
| `indexable_models` | Array | `nil` | Custom models to index |

---

## Models

### Conversation

#### Class Methods

##### `Conversation.create!(attributes)`

Creates a new conversation.

**Parameters:**
- `attributes` (Hash) - Conversation attributes

**Returns:** `Conversation`

**Example:**
```ruby
conversation = RailsChatbot::Conversation.create!(
  user_id: current_user&.id,
  title: "Support Chat"
)
```

##### `Conversation.for_user(user_id)`

Returns conversations for a specific user.

**Parameters:**
- `user_id` (Integer) - User identifier

**Returns:** `ActiveRecord::Relation`

#### Instance Methods

##### `add_user_message(content)`

Adds a user message to the conversation.

**Parameters:**
- `content` (String) - Message content

**Returns:** `Message`

##### `add_assistant_message(content, metadata: {})`

Adds an assistant message to the conversation.

**Parameters:**
- `content` (String) - Message content
- `metadata` (Hash, optional) - Additional metadata

**Returns:** `Message`

##### `conversation_history`

Returns formatted conversation history for LLM.

**Returns:** `Array<Hash>`

**Example:**
```ruby
[
  { role: 'user', content: 'Hello' },
  { role: 'assistant', content: 'Hi there!' }
]
```

#### Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | Integer | Unique identifier |
| `user_id` | Integer | Associated user ID |
| `title` | String | Conversation title |
| `created_at` | DateTime | Creation timestamp |
| `updated_at` | DateTime | Update timestamp |

---

### Message

#### Class Methods

##### `Message.create!(attributes)`

Creates a new message.

**Parameters:**
- `attributes` (Hash) - Message attributes

**Returns:** `Message`

#### Instance Methods

##### `user_message?`

Returns true if message is from user.

**Returns:** `Boolean`

##### `assistant_message?`

Returns true if message is from assistant.

**Returns:** `Boolean`

#### Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | Integer | Unique identifier |
| `conversation_id` | Integer | Associated conversation |
| `role` | String | `'user'` or `'assistant'` |
| `content` | String | Message content |
| `metadata` | JSON | Additional data |
| `created_at` | DateTime | Creation timestamp |
| `updated_at` | DateTime | Update timestamp |

---

### KnowledgeBase

#### Class Methods

##### `KnowledgeBase.create!(attributes)`

Creates a new knowledge base entry.

**Parameters:**
- `attributes` (Hash) - Knowledge attributes

**Returns:** `KnowledgeBase`

##### `KnowledgeBase.search(query)`

Searches knowledge base for relevant entries.

**Parameters:**
- `query` (String) - Search query

**Returns:** `ActiveRecord::Relation`

##### `KnowledgeBase.index_model(model_class, fields: [])`

Indexes all records of a model class.

**Parameters:**
- `model_class` (Class) - ActiveRecord model class
- `fields` (Array) - Fields to index

**Returns:** `Integer` - Number of indexed records

#### Instance Methods

##### `relevance_score(query)`

Calculates relevance score for a query.

**Parameters:**
- `query` (String) - Search query

**Returns:** `Float`

#### Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | Integer | Unique identifier |
| `title` | String | Entry title |
| `content` | Text | Main content |
| `source_type` | String | Source type (`'help'`, `'model'`, `'custom'`) |
| `source_id` | Integer | Source record ID |
| `source_url` | String | Source URL |
| `created_at` | DateTime | Creation timestamp |
| `updated_at` | DateTime | Update timestamp |

---

## Services

### ChatService

#### Constructor

##### `new(conversation:, api_key: nil)`

Initializes a new chat service.

**Parameters:**
- `conversation` (Conversation) - Conversation instance
- `api_key` (String, optional) - OpenAI API key

**Returns:** `ChatService`

#### Instance Methods

##### `process_message(user_message)`

Processes a user message and generates response.

**Parameters:**
- `user_message` (String) - User's message

**Returns:** `Hash`

**Example:**
```ruby
{
  response: "Here's how to reset your password...",
  knowledge_sources: [
    {
      title: "Password Reset Guide",
      source_type: "help",
      source_url: "/help/password"
    }
  ]
}
```

---

### KnowledgeRetrievalService

#### Constructor

##### `new(query:)`

Initializes knowledge retrieval service.

**Parameters:**
- `query` (String) - Search query

**Returns:** `KnowledgeRetrievalService`

#### Instance Methods

##### `retrieve`

Retrieves relevant knowledge entries.

**Returns:** `Array<KnowledgeBase>`

##### `format_context`

Formats retrieved knowledge as context for LLM.

**Returns:** `String`

---

### LlmService

#### Constructor

##### `new(api_key: nil)`

Initializes LLM service.

**Parameters:**
- `api_key` (String, optional) - OpenAI API key

**Returns:** `LlmService`

#### Instance Methods

##### `chat(messages:, context: nil)`

Sends chat request to OpenAI API.

**Parameters:**
- `messages` (Array) - Message history
- `context` (String, optional) - Additional context

**Returns:** `String` - Assistant response

---

## Utility Classes

### KnowledgeIndexer

#### Class Methods

##### `index_all_models`

Indexes all configured models.

**Returns:** `void`

##### `index_model_class(model_class_name)`

Indexes a specific model class.

**Parameters:**
- `model_class_name` (String/Class) - Model class or name

**Returns:** `void`

##### `add_custom_knowledge(title:, content:, source_type: 'custom', source_id: nil, source_url: nil)`

Adds custom knowledge entry.

**Parameters:**
- `title` (String) - Entry title
- `content` (String) - Entry content
- `source_type` (String) - Source type
- `source_id` (Integer, optional) - Source ID
- `source_url` (String, optional) - Source URL

**Returns:** `KnowledgeBase`

##### `remove_knowledge(source_type:, source_id: nil)`

Removes knowledge entries.

**Parameters:**
- `source_type` (String) - Source type
- `source_id` (Integer, optional) - Source ID

**Returns:** `void`

---

## HTTP API Endpoints

### Chat Interface

#### `GET /chatbot`

Returns the main chat interface.

**Response:** HTML page

#### `GET /chatbot/search?q={query}`

Searches knowledge base.

**Parameters:**
- `q` (String) - Search query

**Response:** JSON array of knowledge entries

**Example:**
```json
[
  {
    "id": 1,
    "title": "Password Reset",
    "content": "To reset your password...",
    "source_type": "help",
    "source_url": "/help/password"
  }
]
```

### Conversations

#### `GET /chatbot/conversations`

Lists conversations.

**Response:** JSON array of conversations

#### `POST /chatbot/conversations`

Creates a new conversation.

**Request Body:**
```json
{
  "title": "Support Chat",
  "user_id": 123
}
```

**Response:** Created conversation object

#### `GET /chatbot/conversations/{id}`

Retrieves a specific conversation.

**Response:** Conversation object with messages

#### `DELETE /chatbot/conversations/{id}`

Deletes a conversation.

**Response:** 204 No Content

### Messages

#### `POST /chatbot/conversations/{id}/messages`

Sends a message to a conversation.

**Request Body:**
```json
{
  "content": "How do I reset my password?"
}
```

**Response:**
```json
{
  "message": {
    "role": "assistant",
    "content": "To reset your password...",
    "created_at": "2026-02-17T17:00:00Z"
  },
  "knowledge_sources": [
    {
      "title": "Password Reset Guide",
      "source_type": "help",
      "source_url": "/help/password"
    }
  ]
}
```

#### `GET /chatbot/conversations/{id}/messages`

Retrieves messages for a conversation.

**Response:** JSON array of messages

---

## Error Responses

All API endpoints return appropriate error responses:

### 400 Bad Request
```json
{
  "error": "Invalid parameters",
  "details": "Content cannot be empty"
}
```

### 401 Unauthorized
```json
{
  "error": "Authentication required",
  "details": "Please provide valid API credentials"
}
```

### 404 Not Found
```json
{
  "error": "Resource not found",
  "details": "Conversation with ID 123 not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error",
  "details": "OpenAI API error: Invalid API key"
}
```

---

## Webhooks and Events

### Conversation Events

RailsChatbot emits the following events that you can subscribe to:

#### `conversation.created`

Fired when a new conversation is created.

**Payload:**
```ruby
{
  conversation_id: 123,
  user_id: 456,
  title: "Support Chat"
}
```

#### `message.created`

Fired when a message is created.

**Payload:**
```ruby
{
  message_id: 789,
  conversation_id: 123,
  role: "user",
  content: "Hello"
}
```

#### `knowledge.indexed`

Fired when knowledge is indexed.

**Payload:**
```ruby
{
  model_class: "User",
  records_count: 150,
  fields: ["name", "email"]
}
```

---

## Rate Limiting

API endpoints are rate-limited to prevent abuse:

| Endpoint | Limit | Period |
|----------|-------|--------|
| POST /conversations/{id}/messages | 100 requests | 1 hour |
| GET /search | 1000 requests | 1 hour |
| Other endpoints | 1000 requests | 1 hour |

Rate limit headers are included in responses:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1645123456
```
