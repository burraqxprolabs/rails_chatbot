require_relative "lib/rails_chatbot/version"

Gem::Specification.new do |spec|
  spec.name        = "rails_chatbot"
  spec.version     = RailsChatbot::VERSION
  spec.authors     = [ "" ]
  spec.email       = [ "" ]
  spec.homepage    = "TODO"
  spec.summary     = "AI-powered chatbot system with knowledge base integration for Rails applications"
  spec.description = "RailsChatbot is a Rails engine that provides an intelligent chatbot system with knowledge base integration. It can answer questions about your application by indexing your models and content, using OpenAI's GPT models for intelligent responses."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.4"
  spec.add_dependency "ruby-openai", "~> 7.0"
  spec.add_development_dependency "pg_search", "~> 2.3"
end
