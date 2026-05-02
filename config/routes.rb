Rails.application.routes.draw do
  devise_for :users, sign_out_via: %i[delete get]

  root to: "dashboard#show"

  get "dashboard", to: "dashboard#show"
  get "my_tasks", to: "my_tasks#index"
  get "team", to: "teams#index"
  get "reports", to: "reports#index"
  get "notifications", to: "notifications#index"

  get "api_token", to: "api_tokens#show"
  post "api_token/regenerate", to: "api_tokens#regenerate"

  resources :projects do
    resources :tasks, except: %i[index]
    patch "tasks/:id/move", to: "tasks#move", as: :move_task
  end

  namespace :api do
    namespace :v1 do
      resources :projects, only: %i[index show create update destroy]
      resources :tasks, only: %i[index show create update destroy]
    end
  end
end
