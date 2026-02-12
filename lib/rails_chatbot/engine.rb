module RailsChatbot
  class Engine < ::Rails::Engine
    isolate_namespace RailsChatbot

    initializer "rails_chatbot.assets.precompile" do |app|
      app.config.assets.precompile += %w[rails_chatbot/application.js rails_chatbot/application.css]
    end

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    initializer "rails_chatbot.load_config" do
      require_relative '../../config/initializers/rails_chatbot' if File.exist?(Rails.root.join('config/initializers/rails_chatbot.rb'))
    end
  end
end
