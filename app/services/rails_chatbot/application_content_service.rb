module RailsChatbot
  class ApplicationContentService
    class << self
      def index_application_content
        return unless RailsChatbot.configuration.enable_knowledge_base_indexing
        
        # Index common application files
        index_readme_files
        index_documentation_files
        index_route_files
        index_model_files
        index_custom_content
      end

      def search_application_content(query)
        # First search in knowledge base
        knowledge_results = KnowledgeRetrievalService.new(query: query).retrieve
        
        # If no results, try to match with predefined responses
        if knowledge_results.empty?
          return [find_default_response(query)]
        end
        
        knowledge_results
      end

      private

      def index_readme_files
        readme_paths = [
          Rails.root.join('README.md'),
          Rails.root.join('README.rdoc'),
          Rails.root.join('doc', 'README.md')
        ]
        
        readme_paths.each do |path|
          next unless File.exist?(path)
          
          content = File.read(path)
          add_knowledge_entry(
            title: "Application Documentation",
            content: extract_summary(content),
            source_type: "documentation",
            source_url: "/docs"
          )
        end
      end

      def index_documentation_files
        doc_dirs = [Rails.root.join('doc'), Rails.root.join('docs')]
        
        doc_dirs.each do |doc_dir|
          next unless Dir.exist?(doc_dir)
          
          Dir.glob("#{doc_dir}/**/*.md").each do |file|
            content = File.read(file)
            title = File.basename(file, '.md').titleize
            
            add_knowledge_entry(
              title: title,
              content: extract_summary(content),
              source_type: "documentation",
              source_url: file.sub(Rails.root.to_s, '')
            )
          end
        end
      end

      def index_route_files
        routes_file = Rails.root.join('config', 'routes.rb')
        return unless File.exist?(routes_file)
        
        content = File.read(routes_file)
        routes_info = extract_routes_info(content)
        
        add_knowledge_entry(
          title: "Available Routes and Features",
          content: routes_info,
          source_type: "routes",
          source_url: "/routes"
        )
      end

      def index_model_files
        models_dir = Rails.root.join('app', 'models')
        return unless Dir.exist?(models_dir)
        
        model_info = []
        Dir.glob("#{models_dir}/**/*.rb").each do |file|
          next if File.basename(file).start_with?('application_', 'concerns/')
          
          content = File.read(file)
          model_name = extract_model_name(content, file)
          next unless model_name
          
          description = extract_model_description(content)
          model_info << "#{model_name}: #{description}" if description.present?
        end
        
        if model_info.any?
          add_knowledge_entry(
            title: "Application Models",
            content: model_info.join("\n"),
            source_type: "models",
            source_url: "/models"
          )
        end
      end

      def index_custom_content
        # Add default service information
        add_knowledge_entry(
          title: "Services",
          content: RailsChatbot.configuration.default_responses[:services],
          source_type: "default",
          source_url: "/services"
        )
      end

      def extract_summary(content)
        # Extract first paragraph or main points
        lines = content.split("\n")
        summary_lines = []
        
        lines.each do |line|
          line = line.strip
          next if line.empty? || line.start_with?('#', '*', '-', '=')
          
          summary_lines << line
          break if summary_lines.length >= 3
        end
        
        summary_lines.join(' ').truncate(500)
      end

      def extract_routes_info(content)
        # Extract route information from routes.rb
        routes = []
        
        # Look for common route patterns
        content.scan(/resources\s+:(\w+)/) do |match|
          routes << "#{match[0].pluralize} management"
        end
        
        content.scan(/get\s+['"]([^'"]+)['"]/) do |match|
          routes << match[0]
        end
        
        if routes.any?
          "Available features: #{routes.join(', ')}"
        else
          "Web application with various features and endpoints"
        end
      end

      def extract_model_name(content, file)
        match = content.match(/class\s+(\w+)/)
        match ? match[1] : File.basename(file, '.rb').camelize
      end

      def extract_model_description(content)
        # Look for comments at the beginning of the class
        lines = content.split("\n")
        description_lines = []
        
        in_comment = false
        lines.each do |line|
          line = line.strip
          
          if line.start_with?('class')
            break
          elsif line.start_with?('#')
            description_lines << line.sub(/^#\s*/, '')
          elsif !line.empty? && description_lines.any?
            break
          end
        end
        
        description_lines.join(' ').truncate(200)
      end

      def add_knowledge_entry(title:, content:, source_type:, source_url: nil)
        # Check if entry already exists
        existing = KnowledgeBase.find_by(
          title: title,
          source_type: source_type,
          source_url: source_url
        )
        
        if existing
          existing.update!(content: content, updated_at: Time.current)
        else
          KnowledgeBase.create!(
            title: title,
            content: content,
            source_type: source_type,
            source_url: source_url
          )
        end
      rescue => e
        Rails.logger.error "Error adding knowledge entry: #{e.message}"
      end

      def find_default_response(query)
        query_lower = query.downcase
        
        case query_lower
        when /services?|what.*service|what.*do.*do/
          {
            title: "Services",
            content: RailsChatbot.configuration.default_responses[:services],
            source_type: "default",
            source_url: "/services"
          }
        when /hello|hi|hey/
          {
            title: "Greeting",
            content: RailsChatbot.configuration.default_responses[:greeting],
            source_type: "default",
            source_url: "/greeting"
          }
        else
          {
            title: "General Response",
            content: RailsChatbot.configuration.default_responses[:no_results],
            source_type: "default",
            source_url: "/general"
          }
        end
      end
    end
  end
end
