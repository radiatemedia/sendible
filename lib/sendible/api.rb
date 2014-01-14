require 'uri'
require 'json'
require 'openssl'
require 'net/http'
require 'base64'
require 'cgi'
require 'rexml/document'

class Sendible
  module API
    URL = 'http://sendible.com/api'.freeze

    RESOURCES = {
      'profiles' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => []
          }
        }
      },
      'profile' => {
        :methods => {
          :get => {
            :version => 2,
            :parameters => []
          }
        }
      },
      'single-sign-on' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => [:redirect_to]
          }
        }
      },
      'user_field' => {
        :methods => {
          :post => {
            :version => 1,
            :parameters => [:field_name, :field_value]
          },
          :put => {
            :version => 1,
            :parameters => [:field_name, :field_value]
          }
        }
      },
      'services' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => [:type, :filter, :per_page, :page]
          }
        }
      },
      'messages' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => [:status, :filter, :per_page, :page, :start, :end, :recipient_ids]
          }
        }
      },
      'message' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => [:message_id]
          },
          :post => {
            :version => 1,
            :parameters => [:send_to, :message_text, :subject, :message_rich_text, :send_date_client, :notify_me, :status, :timezone_offset_client, :recurs, :recurs_until_client, :tags, :media, :queue_id]
          },
          :put => {
            :version => 1,
            :parameters => [:send_to, :message_text, :subject, :message_rich_text, :send_date_client, :notify_me, :status, :timezone_offset_client, :recurs, :recurs_until_client, :tags, :media, :deleted_media, :queue_id]
          },
          :delete => {
            :version => 1,
            :parameters => [:message_id]
          }
        }
      },
      'message-recipients' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => [:message_id]
          }
        }
      },
      'media' => {
        :methods => {
          :post => {
            :version => 1,
            :parameters => [:message_id, :media]
          },
          :delete => {
            :version => 1,
            :parameters => [:file_id]
          }
        }
      },
      'mention-terms' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => []
          }
        }
      },
      'mentions' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => [:term_id, :sentiment, :type, :filter, :per_page, :page]
          }
        }
      },
      'priority-posts' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => [:page, :per_page]
          }
        }
      },
      'priority-post-reply' => {
        :methods => {
          :post => {
            :version => 1,
            :parameters => [:message, :priority_post_id]
          }
        }
      },
      'contacts' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => [:filter, :field_name, :field_value, :per_page, :page]
          }
        }
      },
      'contact' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => [:contact_id]
          },
          :post => {
            :version => 1,
            :parameters => [:first_name, :last_name, :owner_id, :email, :cellphone, :birthday, :sex, :city, :country, :zip, :state, :occupation, :addressline1, :addressline2, :fax, :company, :tel, :image_url, :notes, :preference, :bio, :website_url, :contact_type, :lead_source]
          },
          :put => {
            :version => 1,
            :parameters => [:contact_id, :first_name, :last_name, :owner_id, :email, :cellphone, :birthday, :sex, :city, :country, :zip, :state, :occupation, :addressline1, :addressline2, :fax, :company, :tel, :image_url, :notes, :bio, :contact_type, :lead_source]
          },
          :delete => {
            :version => 1,
            :parameters => [:contact_id]
          }
        }
      },
      'contact_field' => {
        :methods => {
          :post => {
            :version => 1,
            :parameters => [:contact_id, :field_name, :field_value, :field_type]
          }
        }
      },
      'lists' => {
        :methods => {
          :get => {
            :version => 2,
            :parameters => [:type, :list_type]
          }
        }
      },
      'list' => {
        :methods => {
          :get => {
            :version => 2,
            :parameters => [:list_id]
          },
          :post => {
            :version => 2,
            :parameters => [:list_name, :list_type, :consumers, :contributors, :color]
          },
          :put => {
            :version => 2,
            :parameters => [:list_id, :list_name, :consumers, :contributors, :color]
          },
          :delete => {
            :version => 2,
            :parameters => [:list_id]
          }
        }
      },
      'list_items' => {
        :methods => {
          :get => {
            :version => 2,
            :parameters => [:list_id, :per_page, :page, :filter]
          }
        }
      },
      'list_add' => {
        :methods => {
          :post => {
            :version => 2,
            :parameters => [:list_id, :item_id]
          }
        }
      },
      'list_remove' => {
        :methods => {
          :post => {
            :version => 2,
            :parameters => [:list_id, :item_id]
          }
        }
      },
      'shorten' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => [:url]
          }
        }
      },
      'message-reports' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => [:filter, :per_page, :page]
          }
        },
        :version => 1
      },
      'message-report' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => [:report_id]
          }
        }
      },
      'account-details' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => []
          }
        }
      },
      'account-periods' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => [:account_detail_id]
          }
        }
      },
      'account-statistics' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => [:account_detail_id, :yearmonth]
          }
        }
      },
      'account-posts' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => [:account_detail_id, :account_statistic_id]
          }
        }
      },
      'user' => {
        :methods => {
          :post => {
            :version => 1,
            :parameters => [:white_label_code, :account_type_id, :fullname, :email, :password, :login, :timezone]
          },
          :put => {
            :version => 1,
            :parameters => [:white_label_code, :account_type_id, :tokens, :disable]
          }
        }
      },
      'account_types' => {
        :methods => {
          :get => {
            :version => 1,
            :parameters => [:white_label_code]
          }
        }
      }
    }.freeze

    class Request
      attr_accessor :params

      def initialize(resource_config, parent)
        @resource_config = resource_config
        @parent = parent
      end

      def set_method_config(http_method)
        @http_method = http_method
        @method_config = @resource_config[:methods][@http_method]
      end

      def request_body_permitted?
        [:post, :put].include?(@http_method)
      end

      [:get, :post, :put, :delete].each do |method_name|
        define_method(method_name) do |*args|
          unless @resource_config[:methods][method_name]
            raise ArgumentError.new("The #{method_name} operation is not supported for this resource")
          end

          @params = args[0] || {}
          set_method_config(method_name)

          self
        end
      end

      def access_token(force = false)
        return @parent.access_token if @parent.access_token && !force

        token = fetch_access_token
        validate_access_token(token)

        @parent.access_token = token
      end

      def uri
        set_method_config(:get) unless @http_method

        URI.parse(Sendible::API::URL + "/v#{@method_config[:version]}/#{@resource_config[:resource]}.json").tap do |uri|
          unless request_body_permitted?
            uri.query = URI.encode_www_form (@params || {}).merge(global_params)
          end
        end
      end

      def response
        request_class = Net::HTTP.const_get(@http_method.to_s.capitalize)
        request_obj = request_class.new(uri.request_uri)
        if request_body_permitted?
          request_obj.set_form_data((@params || {}).merge(global_params))
        end
        response = Net::HTTP.start(uri.host, uri.port) do |http|
          http.request(request_obj)
        end
        JSON::parse response.body
      end

      private

      def global_params
        {
          'application_id' => Sendible.application_id,
          'access_token' => access_token
        }
      end

      def access_key
        timestamp = Time.now.to_i
        access_key = JSON.dump({
          :user_login => @parent.username,
          :user_api_key => @parent.api_key,
          :timestamp => timestamp
        })

        cipher = OpenSSL::Cipher::AES256.new(:CBC)
        cipher.encrypt

        cipher.key = Base64.decode64(Sendible.shared_key)
        cipher.iv = Base64.decode64(Sendible.shared_iv)

        Base64.encode64(cipher.update(access_key) + cipher.final).gsub("\n", "")
      end

      #the "auth" resource is an outlier: it doesn't support json, and it can't take an access key,
      #since it's the method that gives us the access key.
      def fetch_access_token
        uri = URI.parse Sendible::API::URL + "/v1/auth?app_id=#{CGI.escape(Sendible.application_id)}&access_key=#{CGI.escape(access_key)}"
        get = Net::HTTP::Get.new(uri.request_uri)
        response = Net::HTTP.start(uri.host, uri.port) do |http|
          http.request(get)
        end
        response.body
      end

      def validate_access_token(token)
        if token.match(/^<error/)
          doc = REXML::Document.new token
          error_message = nil
          doc.root.elements.each('message') {|element| error_message = element.text}

          raise error_message ? error_message : "Unable to get access_token: #{token}"
        end

        true
      end
    end

    def load_resource(resource_name)
      resource = resource_name.to_s.dup
      unless resource_config = Sendible::API::RESOURCES[resource]
        resource = resource.gsub(/_/, '-')
        resource_config = Sendible::API::RESOURCES[resource]
      end
      resource_config.merge(:resource => resource)
    end

    def method_missing(method_name, *args, &block)
      resource_config = load_resource(method_name)
      if resource_config
        Sendible::API::Request.new(resource_config, self)
      else
        super
      end
    end

    def respond_to?(method_name, include_all = false)
      return true if load_resource(method_name)

      super
    end
  end
end
