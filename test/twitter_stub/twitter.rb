# forces the Twitter gem to use files from the xml directory instead of querying twitter
# no more rate limits being hit, w00t!
# filesnames are paths with /'s replaced with -'s
require 'mocha'
require 'fakeweb'

module Twitter
  class Request

    FakeWeb.allow_net_connect = false

    $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../..', 'lib'))
    $LOAD_PATH.unshift(File.dirname(__FILE__))

    def self.get(url, filename, status=nil)
      url = url =~ /^http/ ? url : "http://twitter.com:80#{url}"

      options = {:string => fixture_file(filename)}
      options.merge!({:status => status}) unless status.nil?

      FakeWeb.register_uri(:get, url, options)
    end

    def perform_post(url, filename)
      FakeWeb.register_uri(:post, "http://twitter.com:80#{url}", :string => fixture_file(filename))
    end

    private
    def fixture_file(filename)
      return '' if filename == ''
      file_path = File.expand_path(File.dirname(__FILE__) + '/json/' + filename)
      File.read(file_path)
    end
  end
end
