Rails.application.routes.draw do
  devise_for :users, sign_out_via: %i[delete get]

  root to: "projects#index"

  resources :projects do
    resources :tasks, except: %i[index]
  end

  namespace :api do
    namespace :v1 do
      resources :projects, only: %i[index show create update destroy]
      resources :tasks, only: %i[index show create update destroy]
    end
  end
end
