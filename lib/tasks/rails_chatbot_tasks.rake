namespace :rails_chatbot do
  desc "Index models into knowledge base"
  task :index_models, [:model_names] => :environment do |_t, args|
    model_names = args[:model_names]&.split(',') || []
    
    if model_names.empty?
      puts "Usage: rake rails_chatbot:index_models[ModelName1,ModelName2]"
      puts "Example: rake rails_chatbot:index_models[User,Post,Comment]"
      exit
    end

    model_names.each do |model_name|
      begin
        model_class = model_name.constantize
        puts "Indexing #{model_name}..."
        RailsChatbot::KnowledgeBase.index_model(model_class)
        puts "✓ Indexed #{model_name}"
      rescue NameError
        puts "✗ Error: Model #{model_name} not found"
      rescue => e
        puts "✗ Error indexing #{model_name}: #{e.message}"
      end
    end
    
    puts "\nDone!"
  end

  desc "Index application content for knowledge base"
  task index_application_content: :environment do
    puts "Indexing application content..."
    RailsChatbot::ApplicationContentService.index_application_content
    puts "Application content indexed successfully!"
  end

  desc "Add default knowledge entries"
  task add_default_knowledge: :environment do
    puts "Adding default knowledge entries..."
    
    RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
      title: "Services",
      content: RailsChatbot.configuration.default_responses[:services],
      source_type: "default",
      source_url: "/services"
    )
    
    puts "Default knowledge entries added!"
  end

  desc "Setup chatbot (index content + add defaults)"
  task setup: :environment do
    puts "Setting up RailsChatbot..."
    Rake::Task['rails_chatbot:index_application_content'].invoke
    Rake::Task['rails_chatbot:add_default_knowledge'].invoke
    puts "RailsChatbot setup complete!"
  end

  desc "Clear knowledge base"
  task clear_knowledge_base: :environment do
    count = RailsChatbot::KnowledgeBase.count
    RailsChatbot::KnowledgeBase.delete_all
    puts "Cleared #{count} knowledge base entries"
  end

  desc "Reindex all ActiveRecord models"
  task index_all: :environment do
    puts "Indexing all ActiveRecord models..."
    
    RailsChatbot::KnowledgeIndexer.index_all_models
    
    puts "\nDone!"
  end

  desc "Add custom knowledge to the base"
  task :add_knowledge, [:title, :content, :source_type] => :environment do |_t, args|
    title = args[:title]
    content = args[:content]
    source_type = args[:source_type] || 'custom'
    
    if title.blank? || content.blank?
      puts "Usage: rake rails_chatbot:add_knowledge['Title','Content','SourceType']"
      puts "Example: rake rails_chatbot:add_knowledge['API Documentation','Use the API endpoint...','docs']"
      exit
    end

    begin
      RailsChatbot::KnowledgeIndexer.add_custom_knowledge(
        title: title,
        content: content,
        source_type: source_type
      )
      puts "✓ Added knowledge entry: #{title}"
    rescue => e
      puts "✗ Error adding knowledge: #{e.message}"
    end
  end

  desc "Show knowledge base statistics"
  task stats: :environment do
    total = RailsChatbot::KnowledgeBase.count
    by_source = RailsChatbot::KnowledgeBase.group(:source_type).count
    
    puts "Knowledge Base Statistics:"
    puts "Total entries: #{total}"
    puts "By source type:"
    by_source.each do |source_type, count|
      puts "  #{source_type}: #{count}"
    end
  end
end

