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
      exception = LoomException.new 'helicoid', 'alex@example.com', 'test'
      exception.session = OpenStruct.new :user_id => '1'
      exception.cookies = []
      exception.request_parameters = []
      exception.url = 'http://example.com'
      exception.user_id = '1'
      exception.exception = options[:exception] || ZeroDivisionError.new
      exception.project_id = 1
      exception.remote_ip = '127.0.0.1'
      exception
    end
end
