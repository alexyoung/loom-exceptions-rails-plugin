require 'pp'
require 'net/http'

class LoomException
  attr_accessor :session, :cookies, :request_parameters, :url, :user_id, :exception, :remote_ip
  
  class LoomDown < Exception ; end
  class LoomError < Exception ; end
  
  def initialize(url, api_key)
    @loom_login = { :url => url, :api_key => api_key }
  end
  
  def send_to_loom
    response = post
    
    if response.code.match /^2/
      true
    else
      puts response.message
      puts response.body
    end
  end
  
  def self.log(url, api_key, &block)
    loom = new url, api_key
    yield loom
    loom.send_to_loom
  rescue LoomDown # TODO
    # Timed out or Loom down.  Log the error and optionally email the administrator.
  rescue LoomError # TODO
    # We sent an invalid request.  Log the error and optionally email the administrator.
  rescue Exception # TODO
    # Something else happened, log it.  The user will be shown an error page so they
    # can acknowledge the issue and continue using the application.
  end
  
  private
    def post
      url = URI.parse "#{@loom_login[:url]}/report/#{@loom_login[:api_key]}"
    
      req = Net::HTTP::Post.new url.path
      req.add_field 'Accept', 'application/x-www-form-urlencoded'
      req.add_field 'Content-Type', 'application/x-www-form-urlencoded'
      req.set_form_data({ :remote_exception => loom_parameters.to_yaml })
      connection = Net::HTTP.new(url.host, url.port)
      connection.request req
    end

    def loom_parameters
      {
        :title => "#{@exception.class}: #{@exception.to_s}",
        :details => { :session_variables => @session.dup,
                      :cookies => @cookies.dup,
                      :request_parameters => @request_parameters.dup,
                      :url => @url,
                      :user_id => @user_id,
                      :remote_ip => @remote_ip,
                      :stack_trace => stack_trace }
      }
    end
    
    def stack_trace
      return '' unless @exception.backtrace
      @exception.backtrace.join("\n")
    end
end
