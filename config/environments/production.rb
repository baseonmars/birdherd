# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests


# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_view.cache_template_loading            = true
config.action_controller.perform_caching  = true
config.cache_classes = true
config.cache_store = :mem_cache_store, '127.0.0.1:11211', {:namespace => "production"}

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!  

ActionMailer::Base.delivery_method = :sendmail
SITE[:api_key] = 'gEn3FWqYxpDq4lQdjzA'
SITE[:api_secret] = 'gGR18W7oPFptkDBgjbMnM22hprv1KYZ2rMYZviXsZg'
