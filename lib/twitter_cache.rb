module Twitter
  class Base
    private
    alias_method :perform_get_nocache, :perform_get 
    def perform_get(path, options={})
      key = "#{@client.access_token.token}:#{path.gsub('/', '-')}:#{options.to_a.join}"
      if Rails.cache.exist?(key) 
        return Rails.cache.read(key)
      else
        response = perform_get_nocache(path, options)
        Rails.cache.write(key, response, :expires_in => 1.minutes)
        return response
      end
    end
  end   
end
   
# Add Marshal dump and load hooks for marshes to allow serialization
# when caching api results
class Mash
  def _dump(depth)
    self.to_yaml
  end

  def Mash._load(str)
    YAML.load(str)
  end
end