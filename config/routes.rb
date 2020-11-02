Rails.application.routes.draw do
  resources :cards
  resources :lists
  root controller: :board, action: :show
end
