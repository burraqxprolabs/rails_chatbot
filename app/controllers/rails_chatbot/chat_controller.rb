module RailsChatbot
  class ChatController < ApplicationController
    def index
      # Main chat interface
    end

    def search
      query = params[:q].to_s.strip
      return render json: { results: [] } if query.blank?

      service = KnowledgeRetrievalService.new(query: query, limit: 10)
      results = service.retrieve

      render json: {
        results: results.map do |result|
          {
            title: result[:title],
            content: result[:content].truncate(200),
            source_type: result[:source_type],
            source_id: result[:source_id],
            source_url: result[:source_url]
          }
        end
      }
    end
  end
end
