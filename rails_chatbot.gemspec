require_relative "lib/rails_chatbot/version"

Gem::Specification.new do |spec|
  spec.name        = "rails_chatbot"
  spec.version     = RailsChatbot::VERSION
  spec.authors     = ["Your Name"]
  spec.email       = ["your.email@example.com"]
  spec.homepage    = "https://github.com/yourusername/rails_chatbot"
  spec.summary     = "AI-powered chatbot system with knowledge base integration for Rails applications"
  spec.description = "RailsChatbot is a Rails engine that provides an intelligent chatbot system with knowledge base integration. It can answer questions about your application by indexing your models and content, using OpenAI's GPT models for intelligent responses."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.4"
  spec.add_dependency "ruby-openai", "~> 7.0"
  spec.add_development_dependency "pg_search", "~> 2.3"
end
