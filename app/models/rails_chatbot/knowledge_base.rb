module RailsChatbot
  class KnowledgeBase < ApplicationRecord
    self.table_name = 'rails_chatbot_knowledge_bases'

    begin
      if defined?(PgSearch)
        include PgSearch::Model

        pg_search_scope :search_by_content,
          against: [:title, :content],
          using: {
            tsearch: { prefix: true, any_word: true }
          }
      else
        raise LoadError
      end
    rescue LoadError, NameError
      # Fallback search scope without pg_search (works with any database)
      scope :search_by_content, ->(query) {
        sanitized_query = connection.quote_string(query.to_s)
        where("title LIKE ? OR content LIKE ?", "%#{sanitized_query}%", "%#{sanitized_query}%")
      }
    end

    validates :title, presence: true
    validates :content, presence: true
    validates :source_type, presence: true

    scope :by_source, ->(type, id = nil) {
      scope = where(source_type: type)
      scope = scope.where(source_id: id) if id
      scope
    }

    def self.index_model(model_class, fields: [:name, :description, :content])
      model_class.find_each do |record|
        content_parts = fields.map { |field| record.send(field) if record.respond_to?(field) }.compact
        content_text = content_parts.join("\n\n")

        find_or_initialize_by(
          source_type: model_class.name,
          source_id: record.id.to_s
        ).update!(
          title: record.try(:name) || record.try(:title) || "#{model_class.name} ##{record.id}",
          content: content_text,
          source_url: Rails.application.routes.url_helpers.polymorphic_path(record) rescue nil
        )
      end
    end
  end
end
