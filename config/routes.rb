ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  map.resource :user do |user|
    user.resources :twitter_users, :as => 'accounts'
  end  
  map.resources :twitter_users do |twitter_user|
    twitter_user.resources :twitter_statuses, :as => 'statuses'
    twitter_user.mentions 'mentions', :controller => 'twitter_users', :action => 'mentions'
    twitter_user.history 'history', :controller => 'twitter_users', :action => 'history'
    twitter_user.friends_timeine 'friends_timeline', :controller => 'twitter_users', :action => 'friends_timeline'
  end
  map.resources :twitter_statuses,:as => 'statuses'

  map.resource :user_session  
  map.direct_messages '/twitter_users/:twitter_user_id/direct_messages', :controller => 'twitter_direct_messages', :action => 'index'
  map.connect 'logout' , :controller => 'user_sessions', :action => 'destroy'
  map.connect '/oauth_callback', :controller => 'twitter_users', :action => 'callback'
  map.status_reply '/accounts/:account_id/statuses/:status_id/reply', :controller => 'twitter_statuses', :action =>'reply'
  map.root :controller => "twitter_users", :action => "index"
  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
