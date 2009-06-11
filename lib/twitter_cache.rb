module Twitter
	class Base
		private
		alias_method :perform_get_nocache, :perform_get 
		def perform_get(path, options={})
			key = "#{@client.access_token.token}#{path.gsub('/', '-')}"
			if Rails.cache.exist?(key) 
        Rails.logger.info "got cached response"
				return Rails.cache.read(key)
			else
        Rails.logger.info "generating response"
				response = perform_get_nocache(path, options)
				Rails.cache.write(key, response)
				return response
			end
		end
	end
end
