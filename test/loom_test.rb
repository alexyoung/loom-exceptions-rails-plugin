require 'rubygems'
require 'active_support'
require 'ostruct'
require 'test/unit'
require 'mocha'
require File.dirname(__FILE__) + '/../lib/loom'
require File.dirname(__FILE__) + '/../lib/loom_exception'

class LoomTest < Test::Unit::TestCase
  # Replace this with your real tests.

  def setup
    stub_loom_api
  end
  
  def test_catches_exception
  end

  def test_posts_to_loom
    exception = mock_loom_exception :exception => mock_exception
    assert exception.send_to_loom
  end

  def test_posts_to_loom_with_nil_backtrace
    exception = mock_loom_exception
    assert exception.send_to_loom
  end

  def test_configure
    Helicoid::Loom.configure do |config|
      config.api_key = 'xxx'
    end

    assert_equal 'xxx', Helicoid::Loom.api_key
    assert_equal 'http://loomapp.com', Helicoid::Loom.server
  end

  private

    def mocked_response(options = {})
      OpenStruct.new :code => '200'
    end

    def stub_loom_api
      Net::HTTP.any_instance.stubs(:request).returns mocked_response
    end

    def mock_exception
      exception = nil
      begin
        1 / 0
      rescue Exception => e
        exception = e
      end
      exception
    end

    def mock_loom_exception(options = {})
      exception = LoomException.new 'helicoid', 'xxx'
      exception.session = OpenStruct.new :user_id => '1'
      exception.cookies = [{ :var_1 => [1, 2, 3, 4], :var_2 => { :a => 'b' }}]
      exception.request_parameters = []
      exception.url = 'http://example.com'
      exception.user_id = '1'
      exception.exception = options[:exception] || ZeroDivisionError.new
      exception.remote_ip = '127.0.0.1'
      exception
    end
end
