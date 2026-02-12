module RailsChatbot
  class KnowledgeIndexer
    class << self
      def index_all_models
        return unless RailsChatbot.configuration.enable_knowledge_base_indexing
        
        # Index common Rails models
        index_model_class('User') if defined?(User)
        index_model_class('Product') if defined?(Product)
        index_model_class('Article') if defined?(Article)
        index_model_class('Post') if defined?(Post)
        
        # Index custom models if configured
        if RailsChatbot.configuration.indexable_models
          RailsChatbot.configuration.indexable_models.each do |model_class|
            index_model_class(model_class) if model_class.is_a?(Class) || model_class.constantize rescue nil
          end
        end
      end
      
      def index_model_class(model_class_name)
        model_class = model_class_name.is_a?(Class) ? model_class_name : model_class_name.constantize
        return unless model_class < ActiveRecord::Base
        
        Rails.logger.info "Indexing #{model_class.name} for knowledge base..."
        
        # Determine which fields to index
        fields = get_indexable_fields(model_class)
        return if fields.empty?
        
        # Index all records
        KnowledgeBase.index_model(model_class, fields: fields)
        Rails.logger.info "Indexed #{model_class.count} #{model_class.name} records"
      rescue => e
        Rails.logger.error "Error indexing #{model_class_name}: #{e.message}"
      end
      
      def add_custom_knowledge(title:, content:, source_type: 'custom', source_id: nil, source_url: nil)
        KnowledgeBase.create!(
          title: title,
          content: content,
          source_type: source_type,
          source_id: source_id,
          source_url: source_url
        )
      end
      
      def remove_knowledge(source_type:, source_id: nil)
        scope = KnowledgeBase.where(source_type: source_type)
        scope = scope.where(source_id: source_id) if source_id
        scope.destroy_all
      end
      
      private
      
      def get_indexable_fields(model_class)
        common_fields = [:name, :title, :description, :content, :body, :summary, :overview]
        
        # Get all string/text columns
        string_columns = model_class.columns.select { |col| col.type == :string || col.type == :text }.map(&:name)
        
        # Prioritize common fields, then add other string fields
        fields = common_fields.select { |field| string_columns.include?(field.to_s) }
        fields += string_columns.reject { |col| common_fields.include?(col.to_sym) }
        
        # Limit to reasonable number of fields
        fields.first(5)
      end
    end
  end
end
