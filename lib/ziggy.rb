module Ziggy

  @@active = true

  def self.active=(isActive)
    @@active = isActive
  end

  def cached(*cachable_methods, &block)
    return unless @@active
    @cached_methods ||= []
    @cached_methods_enhanced ||= []
    @cached_methods += cachable_methods
    @key_generator = block
    class << self
      def method_added(method)
        return unless @cached_methods.include? method        
        return if @cached_methods_enhanced.include? method
        @cached_methods_enhanced << method
        method_without_cache = "#{method}_without_cache".to_sym
        class_eval do 
          alias_method method_without_cache, method 
          define_method(method) do |*args|
            invocation_key = "#{method}#{ args.collect{ |a| a.to_s } }"
            differentiator = (@key_generator.call unless @key_generator.nil?) || ""
            key = invocation_key + differentiator
            return Rails.cache.read(key) if Rails.cache.exist?(key)
            result = send(method_without_cache, *args)
            Rails.cache.write(key, result, :expires_in => 2.5.minutes)
            result
          end
        end
        logger.debug "Caching added to #{self}.#{method}"
      end  
    end
  end

end