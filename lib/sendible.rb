module Sendible
  class << self
    #all of the configurable attributes
    attr_accessor :application_id, :shared_key, :shared_iv
  end

  def self.configure
    yield self
  end
end
