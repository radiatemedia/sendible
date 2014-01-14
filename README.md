sendible
========

An interface to the Sendible API

#Usage

Sendible provides a straightforward interface to sendible's web API (see [https://code.google.com/p/sendible-api/](https://code.google.com/p/sendible-api/)).  For better security, the gem only supports the access key method of authentication.

##Installation
gem install sendible
```ruby
require 'sendible'
```

##Configuration
```ruby
Sendible.configure do |config|
  config.application_id = 'MY_APPLICATION_ID'
  config.shared_key = 'MY_SHARED_KEY'
  config.shared_iv = 'MY_SHARED_IV'
end
```

To get your application id, shared key, and shared initial value ("iv"), please create an application, and see step 1 of [https://snd-store.s3.amazonaws.com/developers/Login%20for%20Developer%20Apps.pdf](https://snd-store.s3.amazonaws.com/developers/Login%20for%20Developer%20Apps.pdf).

##Instantiation
After configuring Sendible, create an object with the credentials of a specific user.
```ruby
sendible = Sendible.new('your_username', 'your_api_key')
```

##Sendible resource endpoints
Sendible's resource endpoints are available as methods on any Sendible instance.
```ruby
sendible.single_sign_on.get.response
sendible.message.get(:message_id => '12345').response
sendible.contact.get(:contact_id => '12345').response
```

##HTTP verbs
Sendible endpoints support a variety of HTTP verbs. These are handled naturally as an extension of the endpoint method. Parameters can be passed to any http verb method.

```ruby
sendible.message.get(:message_id => '12345').response
sendible.message.post(:send_to => '12345,23456', :message_text => 'A great message').response
sendible.message.put(:message_id => '12345', :message_text => 'Another great message').response
sendible.message.delete(message_id => '12345')
```

##URIs
The sendible gem can be used to generate URIs for any Sendible server resource, which is very useful for single sign on, which will not use a server-side call.

```ruby
sendible = Sendible.new('your_username', 'your_api_key')
uri = sendible.single_sign_on.get.url #-> "http://sendible.com/api/v1/single-sign-on?application_id=your_application_id&access_token=123456"
```

##Responses
Sendible JSON is parsed and returned as a hash by the "response" method of any request.

```ruby
response = sendible.shorten.get(url: 'http://google.com/') #-> {"result"=>{"status"=>"success", "url"=>"http://bit.ly/prv5uN"}}
```

#Development
We have not used every sendible endpoint, and if you have problems, we welcome pull requests with tests.  The code is tested with minitest.  The tests can be run with:
```bash
ruby test/sendible_test.rb
```
If you are using bundler (which is probably a good idea), you can use bundler to run the tests:
```bash
bundle exec ruby test/sendible_test.rb
```
