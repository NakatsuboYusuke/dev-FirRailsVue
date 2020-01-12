Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  # namespece で指定のパスを設定
  namespace :api, { format: 'json' } do
    namespace :v1 do
      resources :employees, only: [:index, :show]
    end
  end
  resources :homes, only: [:index]
  root to: 'homes#index'
end
