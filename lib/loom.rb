module Helicoid
  module Loom
    class << self
      attr_accessor :api_key, :server, :before_action, :user_id

      def enable
        ActionController::Base.class_eval do
          include Reporter
        end
      end

      def configure
        yield self

        self.server ||= 'http://loomapp.com'

        if defined?(ActionController::Base) && !ActionController::Base.include?(Helicoid::Loom::Reporter)
          enable
        end
      end
    end
    
    module Reporter
      def self.included(base)
        base.send(:alias_method, :rescue_action_in_public_without_loom, :rescue_action_in_public)
        base.send(:alias_method, :rescue_action_in_public, :send_to_loom)
      end

      def send_to_loom(exception)
        raise if local_request?
        
        send(Helicoid::Loom.before_action) if Helicoid::Loom.before_action
        
        user_id = case Helicoid::Loom.user_id
        when Proc
          Helicoid::Loom.user_id.bind(self).call
        when Symbol, String
          send Helicoid::Loom.user_id
        end
        
        LoomException.log Helicoid::Loom.server, Helicoid::Loom.api_key do |loom|
          loom.session = session.data
          loom.remote_ip = request.remote_ip
          loom.exception = exception
          loom.cookies = request.cookies
          loom.request_parameters = request.parameters
          loom.url = request.request_uri
          loom.user_id = user_id
        end

        rescue_action_in_public_without_loom exception
      end
    end
    
    module ClassMethods
      def logger
        ActiveRecord::Base.logger
      end

      def enable_loom(options = {})
        logger.warn "enable_loom has been removed.  Please use config/initializers/loom.rb or call Helicoid::Loom.configure."
      end
    end
  end
end
