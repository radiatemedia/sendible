$:.push File.expand_path("../../lib", __FILE__)
gem 'minitest'
require 'minitest/autorun'
require 'webmock/minitest'
require 'sendible'

describe Sendible do
  describe '::configure' do
    it "should handle the standard parameters" do
      application_id = 'abc'
      shared_key = 'def'
      shared_iv = '123'
      Sendible.configure do |config|
        config.application_id = application_id
        config.shared_key = shared_key
        config.shared_iv = shared_iv
      end

      Sendible.application_id.must_equal application_id
      Sendible.shared_key.must_equal shared_key
      Sendible.shared_iv.must_equal shared_iv
    end

    it "should chain nicely" do
      Sendible.configure {}.must_equal Sendible
    end
  end

  describe "#new" do
    it "should set the username and api key" do
      username = 'somebody'
      api_key = '123456'
      sendible = Sendible.new username, api_key
      sendible.username.must_equal username
      sendible.api_key.must_equal api_key
    end
  end

  describe "sendible resource" do
    before do
      @application_id = 'the_application_id'
      @shared_key = "aGVsbG8=\n"
      @shared_iv = "d29ybGQ=\n"
      Sendible.configure do |config|
        config.application_id = @application_id
        config.shared_key = @shared_key
        config.shared_iv = @shared_iv
      end

      @username = 'the_username'
      @api_key = 'the_api_key'
      @sendible = Sendible.new(@username, @api_key)

      stub_request(:any, /sendible.com/).to_return(:body => "{\"result\":{\"status\":\"success\"}}")
    end

    Sendible::API::RESOURCES.each do |resource, resource_config|
      resource_config[:methods].each do |http_method, config|
        it "#{resource} should all successfully generate a url with http method #{http_method}" do
          request = @sendible.send(resource.downcase.to_sym).send(http_method)
          request.stub :access_token, 'the_access_token' do
            url = request.uri.to_s
  
            url.must_match /http:\/\/sendible.com\/api\/v\d\/#{resource}\.json/
            case http_method
            when :get, :delete
              url.must_match /json\?application_id=#{@application_id}&access_token=the_access_token/
            else
              url.must_match /json$/
            end
          end
        end

        it "#{resource} should successfully handle a response with http method #{http_method}" do
          request = @sendible.send(resource.downcase.to_sym).send(http_method)
          request.stub :access_token, 'the_access_token' do
            response = request.response
            response['result']['status'].must_equal('success')
          end
        end
      end
    end
  end
end

