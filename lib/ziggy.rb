module Ziggy

  @@active = true

  def self.active=(isActive)
    @@active = isActive
  end

  def cached(cachable_method)
    return unless @@active
    @cached_methods ||= []
    @cached_methods_enhanced ||= []
    @cached_methods << cachable_method
    class << self
      def method_added(method)
        return unless @cached_methods.include? method        
        return if @cached_methods_enhanced.include? method
        @cached_methods_enhanced << method
        method_without_cache = "#{method}_without_cache".to_sym
        class_eval do 
          alias_method method_without_cache, method 
          define_method(method) do |*args|
            key = "#{method}#{ args.collect{ |a| a.to_s } }"
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