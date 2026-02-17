# Deployment Guide

This guide covers how to deploy RailsChatbot in various environments and production considerations.

## Production Setup

### Environment Variables

Configure these environment variables in production:

```bash
# OpenAI Configuration
OPENAI_API_KEY=sk-your-production-api-key
OPENAI_MODEL=gpt-4o-mini

# Database Configuration
DATABASE_URL=postgresql://user:password@host:port/database

# Rails Configuration
RAILS_ENV=production
SECRET_KEY_BASE=your-secret-key-base

# Optional: Custom Configuration
RAILS_CHATBOT_TITLE=Production Assistant
RAILS_CHATBOT_ENABLE_INDEXING=true
```

### Database Configuration

#### PostgreSQL Setup

```sql
-- Create database
CREATE DATABASE rails_chatbot_production;

-- Create user
CREATE USER chatbot_user WITH PASSWORD 'secure_password';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE rails_chatbot_production TO chatbot_user;

-- Enable required extensions
\c rails_chatbot_production;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;
```

#### Database.yml Configuration

```yaml
# config/database.yml
production:
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  database: <%= ENV.fetch("DATABASE_NAME") { "rails_chatbot_production" } %>
  username: <%= ENV.fetch("DATABASE_USERNAME") %>
  password: <%= ENV.fetch("DATABASE_PASSWORD") %>
  host: <%= ENV.fetch("DATABASE_HOST") { "localhost" } %>
  port: <%= ENV.fetch("DATABASE_PORT") { 5432 } %>
  sslmode: <%= ENV.fetch("DATABASE_SSL_MODE") { "prefer" } %>
```

### Asset Configuration

```ruby
# config/environments/production.rb
Rails.application.configure do
  # Enable asset compilation
  config.assets.compile = false
  config.assets.digest = true
  
  # Serve static files
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  
  # Enable caching
  config.action_controller.perform_caching = true
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'],
    expires_in: 30.minutes
  }
end
```

## Deployment Platforms

### Heroku

#### Setup

```bash
# Create Heroku app
heroku create your-app-name

# Add PostgreSQL addon
heroku addons:create heroku-postgresql:essential-0

# Add Redis for caching (optional)
heroku addons:create heroku-redis:hobby-dev

# Set environment variables
heroku config:set OPENAI_API_KEY=your-api-key
heroku config:set RAILS_MASTER_KEY=`cat config/master.key`
heroku config:set RAILS_SERVE_STATIC_FILES=true
```

#### Procfile

```procfile
# Procfile
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
```

#### Puma Configuration

```ruby
# config/puma.rb
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

preload_app!

port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }

plugin :tmp_restart
```

#### Deploy Commands

```bash
# Push to Heroku
git push heroku main

# Run migrations
heroku run rails db:migrate

# Seed knowledge base
heroku run rails rails_chatbot:seed_knowledge

# Open app
heroku open
```

### AWS Elastic Beanstalk

#### Setup

```bash
# Install EB CLI
pip install awsebcli

# Initialize application
eb init rails-chatbot

# Create environment
eb create production
```

#### Configuration Files

```yaml
# .ebextensions/01_environment.config
option_settings:
  aws:elasticbeanstalk:application:environment:
    RAILS_ENV: production
    RAILS_MASTER_KEY: placeholder
    OPENAI_API_KEY: placeholder
    DATABASE_URL: placeholder

  aws:elasticbeanstalk:container:ruby:
    ruby_version: 3.2
    bundler_version: 2.4
```

```yaml
# .ebextensions/02_database.config
Resources:
  AWSEBPostgresDB:
    Type: AWS::RDS::DBInstance
    Properties:
      DBInstanceIdentifier: rails-chatbot-db
      AllocatedStorage: 20
      DBInstanceClass: db.t3.micro
      Engine: postgres
      EngineVersion: "14.9"
      MasterUsername: postgres
      MasterUserPassword: secure_password
```

### Docker Deployment

#### Dockerfile

```dockerfile
# Dockerfile
FROM ruby:3.2-alpine

# Install dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    nodejs \
    npm \
    git

# Set working directory
WORKDIR /app

# Copy gem files
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Precompile assets
RUN bundle exec rails assets:precompile 2>/dev/null || bundle exec rails assets:precompile

# Set permissions
RUN addgroup -g 1000 -S app && \
    adduser -S app -G app -u 1000 && \
    chown -R app:app /app
USER app

# Expose port
EXPOSE 3000

# Start command
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

#### Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=postgresql://postgres:password@db:5432/rails_chatbot
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    volumes:
      - ./log:/app/log

  db:
    image: postgres:14-alpine
    environment:
      - POSTGRES_DB=rails_chatbot
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

  sidekiq:
    build: .
    command: bundle exec sidekiq -C config/sidekiq.yml
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=postgresql://postgres:password@db:5432/rails_chatbot
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis

volumes:
  postgres_data:
  redis_data:
```

### Kubernetes Deployment

#### Deployment Manifest

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rails-chatbot
spec:
  replicas: 3
  selector:
    matchLabels:
      app: rails-chatbot
  template:
    metadata:
      labels:
        app: rails-chatbot
    spec:
      containers:
      - name: app
        image: your-registry/rails-chatbot:latest
        ports:
        - containerPort: 3000
        env:
        - name: RAILS_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database-url
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: openai-api-key
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

#### Service Manifest

```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: rails-chatbot-service
spec:
  selector:
    app: rails-chatbot
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: LoadBalancer
```

## Performance Optimization

### Database Optimization

```sql
-- Add indexes for better performance
CREATE INDEX CONCURRENTLY index_knowledge_bases_on_title_gin 
ON rails_chatbot_knowledge_bases USING gin(title gin_trgm_ops);

CREATE INDEX CONCURRENTLY index_knowledge_bases_on_content_gin 
ON rails_chatbot_knowledge_bases USING gin(content gin_trgm_ops);

CREATE INDEX CONCURRENTLY index_conversations_on_user_id 
ON rails_chatbot_conversations(user_id);

CREATE INDEX CONCURRENTLY index_messages_on_conversation_id 
ON rails_chatbot_messages(conversation_id);

-- Partition large tables if needed
CREATE TABLE rails_chatbot_messages_y2024m01 PARTITION OF rails_chatbot_messages
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

### Caching Strategy

```ruby
# config/environments/production.rb
Rails.application.configure do
  # Knowledge base caching
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'],
    expires_in: 1.hour,
    namespace: 'rails_chatbot'
  }
end

# app/services/rails_chatbot/cached_knowledge_service.rb
module RailsChatbot
  class CachedKnowledgeService
    def self.search(query)
      cache_key = "knowledge_search:#{Digest::MD5.hexdigest(query)}"
      
      Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
        KnowledgeBase.search(query).to_a
      end
    end
  end
end
```

### Background Jobs

```ruby
# app/jobs/rails_chatbot/knowledge_indexing_job.rb
module RailsChatbot
  class KnowledgeIndexingJob < ApplicationJob
    queue_as :default
    
    def perform(model_class_name)
      KnowledgeIndexer.index_model_class(model_class_name)
    end
  end
end

# Schedule periodic indexing
# config/schedule.rb (whenever gem)
every 1.hour do
  runner "RailsChatbot::KnowledgeIndexingJob.perform_later('User')"
  runner "RailsChatbot::KnowledgeIndexingJob.perform_later('Product')"
end
```

## Monitoring and Logging

### Application Monitoring

```ruby
# config/initializers/rails_chatbot_monitoring.rb
RailsChatbot.configure do |config|
  # Add monitoring hooks
  config.chat_service_hooks = {
    before_process: ->(message) { 
      Rails.logger.info "Processing message: #{message[0..50]}..." 
    },
    after_process: ->(result) { 
      Rails.logger.info "Response generated in #{result[:processing_time]}ms" 
    },
    on_error: ->(error) { 
      Rails.logger.error "Chat service error: #{error.message}" 
      # Send to monitoring service
      Sentry.capture_exception(error) if defined?(Sentry)
    }
  }
end
```

### Health Check Endpoint

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Health check
  get '/health', to: 'health#index'
  
  mount RailsChatbot::Engine => "/chatbot"
end

# app/controllers/health_controller.rb
class HealthController < ApplicationController
  def index
    # Check database
    db_status = ActiveRecord::Base.connection.execute('SELECT 1').any?
    
    # Check OpenAI API
    openai_status = check_openai_api
    
    status = db_status && openai_status ? 200 : 503
    
    render json: {
      status: status == 200 ? 'healthy' : 'unhealthy',
      database: db_status ? 'connected' : 'disconnected',
      openai: openai_status ? 'available' : 'unavailable',
      timestamp: Time.current.iso8601
    }, status: status
  end
  
  private
  
  def check_openai_api
    return true unless Rails.env.production?
    
    begin
      client = OpenAI::Client.new(access_token: RailsChatbot.configuration.openai_api_key)
      response = client.models.list
      response&.dig('data')&.any?
    rescue
      false
    end
  end
end
```

### Log Configuration

```ruby
# config/environments/production.rb
Rails.application.configure do
  # Logging configuration
  config.log_level = :info
  config.log_tags = [:request_id]
  
  # Use JSON formatter for structured logging
  config.log_formatter = Logger::JSONFormatter.new if defined?(Logger::JSONFormatter)
  
  # Log to stdout for containerized environments
  logger           = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = config.log_formatter
  config.logger    = ActiveSupport::TaggedLogging.new(logger)
end
```

## Security Considerations

### API Security

```ruby
# config/initializers/rails_chatbot_security.rb
RailsChatbot.configure do |config|
  # Rate limiting
  config.rate_limits = {
    messages_per_hour: 100,
    searches_per_hour: 1000
  }
  
  # Content filtering
  config.content_filters = {
    profanity: true,
    personal_info: true,
    malicious_content: true
  }
  
  # Authentication
  config.authenticate_user = proc { |controller| 
    controller.current_user.present? 
  }
end
```

### SSL/TLS Configuration

```ruby
# config/environments/production.rb
Rails.application.configure do
  # Force SSL
  config.force_ssl = true
  
  # HSTS
  config.ssl_options = {
    hsts: {
      expires: 1.year,
      subdomains: true,
      preload: true
    }
  }
end
```

## Scaling Considerations

### Horizontal Scaling

```yaml
# docker-compose.scale.yml
version: '3.8'

services:
  app:
    build: .
    scale: 3
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/rails_chatbot
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - app
```

### Load Balancer Configuration

```nginx
# nginx.conf
upstream rails_chatbot {
    least_conn;
    server app_1:3000 max_fails=3 fail_timeout=30s;
    server app_2:3000 max_fails=3 fail_timeout=30s;
    server app_3:3000 max_fails=3 fail_timeout=30s;
}

server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    
    location / {
        proxy_pass http://rails_chatbot;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /chatbot {
        proxy_pass http://rails_chatbot;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

## Backup and Recovery

### Database Backups

```bash
#!/bin/bash
# scripts/backup_database.sh

BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/rails_chatbot_$TIMESTAMP.sql"

# Create backup
pg_dump $DATABASE_URL > $BACKUP_FILE

# Compress backup
gzip $BACKUP_FILE

# Upload to S3 (optional)
aws s3 cp $BACKUP_FILE.gz s3://your-backup-bucket/database/

# Clean old backups (keep last 7 days)
find $BACKUP_DIR -name "rails_chatbot_*.sql.gz" -mtime +7 -delete
```

### Knowledge Base Backup

```ruby
# lib/tasks/rails_chatbot_backup.rake
namespace :rails_chatbot do
  desc "Backup knowledge base"
  task backup_knowledge: :environment do
    backup_data = {
      timestamp: Time.current.iso8601,
      knowledge_bases: RailsChatbot::KnowledgeBase.all.as_json,
      conversations: RailsChatbot::Conversation.limit(1000).as_json
    }
    
    backup_file = "tmp/rails_chatbot_backup_#{Time.current.to_i}.json"
    File.write(backup_file, JSON.pretty_generate(backup_data))
    
    puts "Backup created: #{backup_file}"
  end
end
```

This deployment guide covers the essential aspects of deploying RailsChatbot to production environments, ensuring scalability, security, and reliability.
