eval File.dirname(__FILE__) + "/development"    

config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false
config.cache_classes = false
config.cache_store = :mem_cache_store, '127.0.0.1:11211', {:namespace => "dev"}