// Chatbot Widget JavaScript
document.addEventListener('DOMContentLoaded', function() {
  const chatbotIcon = document.getElementById('chatbot-toggle');
  const chatbotWindow = document.getElementById('chatbot-window');
  const chatbotClose = document.getElementById('chatbot-close');
  const messagesContainer = document.getElementById('chatbot-messages');
  const input = document.getElementById('chatbot-input');
  const sendButton = document.getElementById('chatbot-send');
  const unreadBadge = document.getElementById('unread-badge');
  
  let conversationId = null;
  let isLoading = false;
  let isWindowOpen = false;

  // Toggle chat window
  function toggleChatWindow() {
    isWindowOpen = !isWindowOpen;
    
    if (isWindowOpen) {
      chatbotWindow.classList.add('open');
      unreadBadge.style.display = 'none';
      input.focus();
    } else {
      chatbotWindow.classList.remove('open');
    }
  }

  // Close chat window
  function closeChatWindow() {
    isWindowOpen = false;
    chatbotWindow.classList.remove('open');
  }

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

  // Show unread indicator
  function showUnreadIndicator() {
    if (!isWindowOpen) {
      unreadBadge.style.display = 'flex';
    }
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
        showUnreadIndicator();
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
  if (chatbotIcon) chatbotIcon.addEventListener('click', toggleChatWindow);
  if (chatbotClose) chatbotClose.addEventListener('click', closeChatWindow);
  if (sendButton) sendButton.addEventListener('click', sendMessage);
  if (input) input.addEventListener('keydown', handleKeyDown);

  // Initialize conversation on load
  initializeConversation();

  // Show welcome message if no messages
  const existingMessages = messagesContainer.querySelectorAll('.message');
  if (existingMessages.length === 0) {
    addMessage('assistant', 'Hello! I\'m your application assistant. How can I help you today?');
  }
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
    conversationsPath: () => '/chatbot/conversations',
    conversationMessagesPath: (id) => `/chatbot/conversations/${id}/messages`,
    messagesPath: () => '/chatbot/messages'
  };
}
