module Sendible
  module API
    METHODS = {
      :profile => {},
      :single_sign_on => {},
      :user_field => {
        :method => 'POST'
      },
      :services => {},
      :messages => {},
      :message => {},
      :message_recipients => {},
      
    }.freeze

    class Request
      attr_accessor :params

      [:get, :post, :put, :delete].each do |method_name|
        define_method(method_name) do |*args|
          @params = args[0] || {}
          @http_method = method_name
          self
        end
      end

      def url
      end

      def response
        #make request
      end
    end

    def method_missing(method_name, *args, &block)
      if METHODS.keys.include?(method_name.to_sym)
        request = Request.new
      else
        super
      end
    end
  end
end
