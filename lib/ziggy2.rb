module Ziggy2

  def self.included(base)
    base.extend ClassMethods
    base.instance_eval do
      @should_be_cached = []
      @cached = []  
    end
  end

  module ClassMethods
    def cached(*cachable_methods, &block)
      @should_be_cached += cachable_methods
      @keygen = block
    end
    
    def should_be_cached?(method)
      @should_be_cached.include? method
    end
    
    def cached?(method)
      @cached.include? method
    end
    
    def method_added(method)
      return unless should_be_cached?(method) && !cached?(method)
      @cached << method
      method_without_cache = "#{method}_without_cache".to_sym
      class_eval do 
        alias_method method_without_cache, method 
        define_method(method) do |*args|
          key = self.class.build_key(self, method, args)
          return Rails.cache.read(key) if Rails.cache.exist?(key)
          result = send(method_without_cache, *args)
          Rails.cache.write(key, result, :expires_in => 2.5.minutes)
          result
        end
      end
      logger.debug "Caching added to #{self}.#{method}"
    end    

    def keygen
      @keygen
    end
    
    def build_key(instance, method, args)
      invocation_key = "#{method}#{ args.collect{ |a| a.to_s } }"
      differentiator = (keygen.call(instance) unless keygen.nil?) || ""
      differentiator + invocation_key
    end    
  end
  
end