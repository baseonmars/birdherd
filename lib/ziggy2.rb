module Ziggy2

  @cached_methods = []

  def self.included(base)
    base.extend ClassMethods
    base.instance_eval do
      @should_be_cached = []
      @cached_methods_enhanced = []  
    end
  end

  module ClassMethods
    def cached(*cachable_methods, &block)
      @should_be_cached += cachable_methods
      @key_generator = block
    end
    
    def should_be_cached?(method)
      @should_be_cached.include? method
    end
    
    def cached?(method)
      @cached_methods_enhanced.include? method
    end
    
    def method_added(method)
      return unless should_be_cached?(method) && !cached?(method)
      @cached_methods_enhanced << method
      method_without_cache = "#{method}_without_cache".to_sym
      class_eval do 
        alias_method method_without_cache, method 
        define_method(method) do |*args|
          key = build_key(method, args)
          return Rails.cache.read(key) if Rails.cache.exist?(key)
          result = send(method_without_cache, *args)
          Rails.cache.write(key, result, :expires_in => 2.5.minutes)
          result
        end
      end
      logger.debug "Caching added to #{self}.#{method}"
    end    

    def key_generator
      @key_generator
    end
  end
  
  def build_key(method, args)
    invocation_key = "#{method}#{ args.collect{ |a| a.to_s } }"
    keygen = self.class.key_generator
    differentiator = (keygen.call(self) unless keygen.nil?) || ""
    differentiator + invocation_key
  end  
  
end