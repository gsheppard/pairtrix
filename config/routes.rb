Pairtrix::Application.routes.draw do
  post '/pusher/auth' => 'pusher#auth'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/auth/failure' => 'sessions#failure'
  get '/sign_out' => 'sessions#destroy', as: 'sign_out'
  get '/sign_in' => redirect('/auth/google_oauth2'), as: 'sign_in'
  get '/dashboard' => 'users#dashboard', as: 'dashboard'

  post '/pairs/ajax_create' => 'pairs#create'
  get '/help' => 'pages#help', as: :help

  resources :sessions
  resources :users
  resources :companies, shallow: true do
    resources :membership_requests, only: [:create, :update, :approve, :deny] do
      member do
        get :approve
        get :deny
      end
    end
    resources :company_memberships
    resources :employees
    resources :teams, shallow: true do
      resources :team_memberships
      resources :pairing_days do
        resources :pairs
      end
    end
  end

  root 'companies#index'
end
