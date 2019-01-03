Rails.application.routes.draw do
  get 'welcome/index'
  # get 'search' => 'search#show'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  resources :measurements
  
  #get '/' => 'welcome#index'
  root 'welcome#index'
  
  
end

