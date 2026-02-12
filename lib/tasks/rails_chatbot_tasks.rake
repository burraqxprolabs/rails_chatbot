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

  desc "Clear knowledge base"
  task clear_knowledge_base: :environment do
    count = RailsChatbot::KnowledgeBase.count
    RailsChatbot::KnowledgeBase.delete_all
    puts "Cleared #{count} knowledge base entries"
  end

  desc "Reindex all ActiveRecord models"
  task index_all: :environment do
    puts "Indexing all ActiveRecord models..."
    
    Rails.application.eager_load!
    models = ActiveRecord::Base.descendants.reject(&:abstract_class?)
    
    models.each do |model|
      begin
        puts "Indexing #{model.name}..."
        RailsChatbot::KnowledgeBase.index_model(model)
        puts "✓ Indexed #{model.name}"
      rescue => e
        puts "✗ Error indexing #{model.name}: #{e.message}"
      end
    end
    
    puts "\nDone!"
  end
end

