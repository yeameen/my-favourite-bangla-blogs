ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

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

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "blog", :action => "posts"

  # restuful authentication
  map.resources :users
  map.resource :session
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil

  map.tag "tag/:tag", :controller => "blog", :action => "tag"

  # See how all your routes lay out with "rake routes"

  map.view_post "post/:id", :controller => "blog", :action => "view_post"
  map.openid "my/login_check", :controller => "my", :action => "login_check", :requirements => {:method => :get}

  # update recommendation
  map.update_recommendation 'recommendation/update/:rec/:id', :controller => 'blog', :action => 'update_recommendation'

  # read post by key
  map.read_by_key "/read/:key", :controller => "blog", :action => "read_post_by_key"

  # cached and bundled javascript/stylesheet
  map.connect ':asset_dir/:names.:ext',
            :controller => 'assets_bundle',
            :action => 'fetch',
            :asset_dir => /(stylesheets|javascripts)/,
            :ext => /(css|js)/,
            :names => /[^.]*/
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
