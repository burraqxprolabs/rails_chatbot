module RailsChatbot
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception, if: -> { request.format.html? }
    skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

    private

    def current_user
      # Override this method in your main application controller
      # or define it in an initializer
      instance_eval(&Rails.application.config.rails_chatbot.current_user_proc) if Rails.application.config.rails_chatbot&.current_user_proc
    end
  end
end
