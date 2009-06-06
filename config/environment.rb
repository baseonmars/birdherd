# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install 
  # development and test gems are specified in their environments
  config.gem "authlogic", :version => '>2.0.4'
	config.gem "twitter", :version => '>=0.6.11' 
	config.gem "mbleigh-acts-as-taggable-on", :source => "http://gems.github.com", :lib => "acts-as-taggable-on"
	config.gem 'oauth'
	config.gem 'vlad'                
	
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  
  SITE = {
    :email => 'team@thebirdherd.com',
    :team_signoff => 'The Birdherd Team',
    :app_name => 'Birdherd',
    :url => 'http://thebirdherd.com',
    :entry_code => 'fre555h', 
    :social_graph_ids_per_page => 5000
  }

  SITE[:email_str] = "#{SITE[:app_name]} <#{SITE[:email]}>"

  config.active_record.observers = :user_observer
  
end

# module Twitter
#   class Base
#     private
#     alias_method :perform_get_nocache, :perform_get 
#     def perform_get(path, options={})
#       key = "#{@client.access_token.token}#{path.gsub('/', '-')}"
#       if Rails.cache.exist?(key) 
#         Rails.logger.info "got cached response"
#         return Rails.cache.read(key)
#       else
#         Rails.logger.info "generating response"
#         response = perform_get_nocache(path, options)
#         # Rails.logger.info response.inspect
#         Rails.cache.write(key, response)
#         return response
#       end
#     end
#   end   
# end     
#      
# module Twitter
#   class Request    
#     alias_method :perform_no_cache, :perform
# 
#     def perform
#       key = "#{@client.client.access_token.token}#{path.gsub('/', '-')}"
#       if Rails.cache.exist?(key)
#         return Rails.cache.read(key)
#       else
#         response = perform_no_cache
#         Rails.logger.info response.inspect
#         Rails.cache.write(key, response)
#         return response
#       end
#     end
#          
#   end
# end
#     


module ActiveSupport
  class BufferedLogger
    def add(severity, message = nil, progname = nil, &block)
      return if @level > severity
      message = (message || (block && block.call) || progname).to_s

      level = {
        0 => "DEBUG",
        1 => "INFO",
        2 => "WARN",
        3 => "ERROR",
        4 => "FATAL"
      }[severity] || "U"

      message = "[%s: %s] %s" % [level,
        Time.now.strftime("%m%d %H:%M:%S"),
        message]

      message = "#{message}\n" unless message[-1] == ?\n
      buffer << message
      auto_flush
      message
    end
  end
end