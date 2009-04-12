# forces the Twitter gem to use files from the xml directory instead of querying twitter
# no more rate limits being hit, w00t!
# filesnames are paths with /'s replaced with -'s
require 'mocha'
require 'fakeweb'
require 'twitter'

FakeWeb.allow_net_connect = false

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))


module Twitter
  class Request

    def self.fixture_file(path)
      return '' if path == ''
      filename = path.gsub(/^\//,'').gsub(/\//,'-')
      file_path = File.expand_path(File.dirname(__FILE__) + '/json/' + filename)
      File.read(file_path)
    end
    
    def self.mash(obj)
      if obj.is_a?(Array)
        obj.map { |item| make_mash_with_consistent_hash(item) }
      elsif obj.is_a?(Hash)
        make_mash_with_consistent_hash(obj)
      else
        obj
      end
    end

    # Lame workaround for the fact that mash doesn't hash correctly
    def self.make_mash_with_consistent_hash(obj)
      m = Mash.new(obj)
      def m.hash
        inspect.hash
      end
      return m
    end
    
     def self.get(base, path, status=nil)
      return mash(Crack::JSON.parse(fixture_file(path)))
    end

    def self.post(base, path, options={})
      return mash(Crack::JSON.parse(fixture_file(path)))
    end

  end
end

module Twitter
  class OAuth
    
    def consumer
      @consumer ||= ::OAuth::Consumer.new(@ctoken, @csecret, {:site => 'http://twitter.com'})
    end
    
    def request_token
      Mash.new(:token => 'token', :secret => 'secret', :authorize_url => 'http://twitter.com/authorize')
    end
    
    def authorize_from_request(rtoken, rsecret)
      ['access_token', 'access_token']
    end
    
    def access_token
      'access_token'
    end
    
    def authorize_from_access(atoken, asecret)
      ['atoken', 'asecret']
    end
  end
  
end