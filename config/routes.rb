Rails.application.routes.draw do

  get  'new'    => 'game#new',   :as => 'new_game'
  post 'create' => 'game#create',:as => 'create_game'
  get  'show'   => 'game#show',  :as => 'game'
  post 'guess'  => 'game#guess', :as => 'guess'
  get  'win'    => 'game#win',   :as => 'win_game'
  get  'lose'   => 'game#lose',  :as => 'lose_game'
  get  'my_measurements' => 'game#my_measurements', :as => 'my_measurements'
  get  'enter_my_measurements' => 'game#enter_my_measurements', :as => 'enter_my_measurements'
  post  'process_enter_new_measurements' => 'game#process_enter_new_measurements', :as => 'process_enter_new_measurements'

  root 'game#new'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end