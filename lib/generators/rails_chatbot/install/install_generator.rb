module RailsChatbot
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def create_initializer
        copy_file 'rails_chatbot.rb', 'config/initializers/rails_chatbot.rb'
      end

      def add_routes
        route "mount RailsChatbot::Engine => '/chatbot'"
      end

      def show_readme
        readme 'README' if behavior == :invoke
      end
    end
  end
end
