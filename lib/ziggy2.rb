module Ziggy2

  @cached_methods = []

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def cached(*cachable_methods, &block)
      @cached_methods ||= []
      @cached_methods_enhanced ||= []
      @cached_methods += cachable_methods
      @key_generator = block
    end
    
    def method_added(method)
      @cached_methods ||= []
      @cached_methods_enhanced ||= []      
      return unless @cached_methods.include? method        
      return if @cached_methods_enhanced.include? method
      @cached_methods_enhanced << method
      method_without_cache = "#{method}_without_cache".to_sym
      class_eval do 
        alias_method method_without_cache, method 
        define_method(method) do |*args|
          invocation_key = "#{method}#{ args.collect{ |a| a.to_s } }"
          keygen = self.class.key_generator
          differentiator = (keygen.call(self) unless keygen.nil?) || ""
          key = differentiator + invocation_key
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
  
  

end