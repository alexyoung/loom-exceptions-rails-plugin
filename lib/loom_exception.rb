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
      req.add_field 'Accept', 'application/xml'
      req.add_field 'Content-Type', 'application/xml'
      
      connection = Net::HTTP.new(url.host, url.port)
      connection.request req, loom_parameters_as_xml
    end

    def loom_parameters_as_xml
      for_xml = loom_parameters.dup
      for_xml[:details].each do |key, value|
        # Convert parameters that can't be converted to XML
        if value.kind_of? Hash
          value.each do |value_key, value_value|
            if incompatible_with_to_xml? value_value
              for_xml[:details][key][value_key] = dump_to_string(value_value)
            end
          end
        elsif incompatible_with_to_xml?(value)
          for_xml[:details][key] = dump_to_string(value)
        end
      end
      
      for_xml = convert_all_keys_to_valid_xml_keys(for_xml)
      for_xml.to_xml(:root => 'remote_exception')
    end
    
    def incompatible_with_to_xml?(value)
      if value.kind_of?(String) or value.kind_of?(Numeric)
        return false
      else
        value.to_xml
      end
      
      return false
    rescue Exception
      return true
    end
    
    def dump_to_string(value)
      PP.pp(value, "")
    rescue Exception
      "Loom error: Unable to parse value as XML"
    end
    
    # Removes keys like -session_id which will break the API
    def convert_all_keys_to_valid_xml_keys(values)
      returning Hash.new do |converted_values|
        values.each do |key, value|
          if value.kind_of? Hash
            converted_values[convert_key_to_xml_key(key)] = convert_all_keys_to_valid_xml_keys(value)
          else
            converted_values[convert_key_to_xml_key(key)] = value
          end
        end
      end
    end
    
    def convert_key_to_xml_key(key)
      key.to_s.sub(/^[^[:alnum:]]/, '')
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
