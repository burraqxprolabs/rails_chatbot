module RailsChatbot
  class KnowledgeRetrievalService
    def initialize(query:, limit: 5)
      @query = query
      @limit = limit
    end

    def retrieve
      return [] if @query.blank?

      # Search knowledge base using pg_search
      results = KnowledgeBase.search_by_content(@query).limit(@limit)

      # Format results for context
      results.map do |kb|
        {
          title: kb.title,
          content: kb.content,
          source_type: kb.source_type,
          source_id: kb.source_id,
          source_url: kb.source_url
        }
      end
    end

    def format_context
      results = retrieve
      return nil if results.empty?

      context_parts = results.map do |result|
        <<~CONTEXT
          Title: #{result[:title]}
          Source: #{result[:source_type]}#{" (ID: #{result[:source_id]})" if result[:source_id]}
          Content: #{result[:content]}
          #{result[:source_url] ? "URL: #{result[:source_url]}" : ""}
        CONTEXT
      end

      context_parts.join("\n\n---\n\n")
    end
  end
end
