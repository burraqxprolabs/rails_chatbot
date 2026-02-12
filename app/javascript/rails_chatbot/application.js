// Chatbot controller using Stimulus (or vanilla JS)
document.addEventListener('DOMContentLoaded', function() {
  const chatbotContainer = document.querySelector('[data-controller="chatbot"]');
  if (!chatbotContainer) return;

  const messagesContainer = chatbotContainer.querySelector('[data-chatbot-target="messages"]');
  const input = chatbotContainer.querySelector('[data-chatbot-target="input"]');
  const sendButton = chatbotContainer.querySelector('[data-chatbot-target="sendButton"]');
  let conversationId = null;
  let isLoading = false;

  // Initialize conversation
  function initializeConversation() {
    fetch(window.RailsChatbot.routes.conversationsPath(), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || ''
      },
      body: JSON.stringify({})
    })
    .then(response => response.json())
    .then(data => {
      conversationId = data.conversation_id;
    })
    .catch(error => console.error('Error initializing conversation:', error));
  }

  // Add message to UI
  function addMessage(role, content, knowledgeSources = []) {
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${role}`;
    
    const bubble = document.createElement('div');
    bubble.className = 'message-bubble';
    bubble.textContent = content;
    
    messageDiv.appendChild(bubble);
    
    if (knowledgeSources && knowledgeSources.length > 0) {
      const sourcesDiv = document.createElement('div');
      sourcesDiv.className = 'knowledge-sources';
      sourcesDiv.innerHTML = 'Sources: ' + knowledgeSources.map(s => {
        if (s.source_url) {
          return `<a href="${s.source_url}" target="_blank">${s.title}</a>`;
        }
        return s.title;
      }).join(', ');
      messageDiv.appendChild(sourcesDiv);
    }
    
    const timeDiv = document.createElement('div');
    timeDiv.className = 'message-time';
    timeDiv.textContent = new Date().toLocaleTimeString();
    messageDiv.appendChild(timeDiv);
    
    messagesContainer.appendChild(messageDiv);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
  }

  // Show loading indicator
  function showLoading() {
    const loadingDiv = document.createElement('div');
    loadingDiv.className = 'message assistant';
    loadingDiv.id = 'loading-message';
    loadingDiv.innerHTML = '<div class="message-bubble"><div class="loading"></div></div>';
    messagesContainer.appendChild(loadingDiv);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
  }

  // Remove loading indicator
  function removeLoading() {
    const loading = document.getElementById('loading-message');
    if (loading) loading.remove();
  }

  // Send message
  function sendMessage() {
    const message = input.value.trim();
    if (!message || isLoading) return;

    // Add user message to UI
    addMessage('user', message);
    input.value = '';
    isLoading = true;
    sendButton.disabled = true;
    showLoading();

    // Determine endpoint
    const url = conversationId 
      ? window.RailsChatbot.routes.conversationMessagesPath(conversationId)
      : window.RailsChatbot.routes.messagesPath();

    // Send to server
    fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || ''
      },
      body: JSON.stringify({ message: message })
    })
    .then(response => response.json())
    .then(data => {
      removeLoading();
      
      if (data.error) {
        addMessage('assistant', `Error: ${data.error}`);
      } else {
        if (!conversationId && data.conversation_id) {
          conversationId = data.conversation_id;
        }
        addMessage('assistant', data.message.content, data.knowledge_sources || []);
      }
    })
    .catch(error => {
      removeLoading();
      addMessage('assistant', 'Sorry, there was an error processing your message. Please try again.');
      console.error('Error:', error);
    })
    .finally(() => {
      isLoading = false;
      sendButton.disabled = false;
      input.focus();
    });
  }

  // Handle key press
  function handleKeyDown(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      sendMessage();
    }
  }

  // Attach event listeners
  sendButton.addEventListener('click', sendMessage);
  input.addEventListener('keydown', handleKeyDown);

  // Initialize conversation on load
  initializeConversation();
});

// Routes helper - populated from server
if (window.RailsChatbot && window.RailsChatbot.routes) {
  const routes = typeof window.RailsChatbot.routes === 'string' 
    ? JSON.parse(window.RailsChatbot.routes) 
    : window.RailsChatbot.routes;
  
  window.RailsChatbot.routes = {
    conversationsPath: () => routes.conversations_path,
    conversationMessagesPath: (id) => routes.conversation_messages_path_template.replace(':id', id),
    messagesPath: () => routes.messages_path
  };
} else {
  // Fallback routes
  window.RailsChatbot = window.RailsChatbot || {};
  window.RailsChatbot.routes = {
    conversationsPath: () => '/rails_chatbot/conversations',
    conversationMessagesPath: (id) => `/rails_chatbot/conversations/${id}/messages`,
    messagesPath: () => '/rails_chatbot/messages'
  };
}
