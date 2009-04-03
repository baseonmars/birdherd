# forces the Twitter gem to use files from the xml directory instead of querying twitter
# no more rate limits being hit, w00t!
# filesnames are paths with /'s replaced with -'s
module Twitter
  class Base
    class StubResponse
      attr_accessor :code, :body
      def initialize(code)
         @code = code.to_s
      end
    end

    TWITTER_API_XML = 'twitter_stub/xml'
        
    def response(path="",options={})
      res = StubResponse.new(200)
      return if path == '/'
      # pretty sure this could look nicer
      File.open("#{Dir.pwd}/test/#{TWITTER_API_XML}/#{path.gsub("/",'-').gsub(/\??/,'')}",'r') do |body|
        res.body = body.read
      end
      res
    end
  end
end
