# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = true 
config.cache_classes                                 = true                                                
config.cache_store = :mem_cache_store, '127.0.0.1:11211', {:namespace => "dev_with_caching"}

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true

ActionMailer::Base.delivery_method = :sendmail

SITE ||= {}
SITE[:url] = 'http://devbirdherd.com:3000'
SITE[:api_key] = 'FhNZIOFLllHvpB2VlEXAA'
SITE[:api_secret] = 'MHXEDctGtssS7VQjLwHHA5lgPlAnWy0Xi6NO2nnRc'
                                        

                                           
config.gem "ruby-debug"                                                                                                   