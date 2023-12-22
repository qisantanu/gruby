Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :sample_files
  root to: 'sample_files#index'
  

  match "/*path", :to => 'errors#not_found', via:[:all]
end
