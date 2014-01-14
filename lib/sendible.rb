require 'sendible/api'
require 'sendible/version'

class Sendible
  class << self
    #all of the configurable attributes
    attr_accessor :application_id, :shared_key, :shared_iv

    def configure
      yield self

      self
    end
  end

  include Sendible::API

  attr_accessor :username, :api_key, :access_token

  def initialize(username, api_key)
    @username = username
    @api_key = api_key
  end
end
