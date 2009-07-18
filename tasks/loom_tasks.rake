# desc "Explaining what the task does"
# task :loom do
#   # Task goes here
# end

namespace :loom do
  desc "Sends a test exception so you can test your settings"
  task :test do
    require 'action_controller/test_process'
    require 'app/controllers/application_controller'

    class ApplicationController
      def test
       puts "Connecting to server: #{Helicoid::Loom.server} with API key: #{Helicoid::Loom.api_key}"
       raise "This is a test error notification"
      end

      def rescue_action(exception)
        rescue_action_in_public exception
      end
    end

    request = ActionController::TestRequest.new
    response = ActionController::TestResponse.new

    request.action = 'test'
    request.request_uri = '/test'

    ApplicationController.process request, response
  end
end
