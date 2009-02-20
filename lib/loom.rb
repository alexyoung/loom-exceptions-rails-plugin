module Helicoid
  module Loom
    def self.enable
      ActionController::Base.class_eval do
        include InstanceMethods
        extend ClassMethods
      end
    end
    
    module InstanceMethods
      def log_with_loom(exception)
        raise if local_request?
        
        send(loom_options[:before_action]) if loom_options.has_key? :before_action
        
        user_id = case loom_options[:user_id]
        when Proc
          loom_options[:user_id].bind(self).call
        when Symbol, String
          send loom_options[:user_id]
        end
        
        LoomException.log loom_options[:url], loom_options[:email], loom_options[:password] do |loom|
          loom.project_id = loom_options[:project_id]
          loom.session = session.data
          loom.remote_ip = request.remote_ip
          loom.exception = exception
          loom.cookies = request.cookies
          loom.request_parameters = request.parameters
          loom.url = request.request_uri
          loom.user_id = user_id
        end
        
        if loom_options.has_key? :display
          send(loom_options[:display])
        else
          raise
        end
      end
    end
    
    module ClassMethods
      def enable_loom(options = {})
        write_inheritable_hash :loom_options, options
        class_inheritable_reader :loom_options

        class_eval <<-RUBY
          rescue_from Exception do |exception|
            log_with_loom exception
          end
        RUBY
      end
    end
  end
end