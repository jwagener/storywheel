Storywheel::Application.routes.draw do
  root to: "stories#index"
  instragram_url = if Rails.env == "production"
    "https://instagram.com/oauth/authorize/?client_id=95ee14ed94f046d89b6746b02ea0ecb5&redirect_uri=http://storywheel.cc/instagram-callback.html&response_type=token"
  else
    "https://instagram.com/oauth/authorize/?client_id=c8b97e3a8e3f4cfe8274ad1c26da1d77&redirect_uri=http://localhost:3000/instagram-callback.html&response_type=token"
  end

  match "/connect-instagram" => redirect(instragram_url), as: :connect_instagram

  match ":user"        => "stories#show"
  match ":user/:track" => "stories#show"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
