Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resources :events do
    resources :groups, except: :index do
      resources :reservations, except: :index
    end
  end

  get "cerca/prenotazioni", to: "searches#reservations", as: :search_reservations

  namespace :public, path: "prenota" do
    root "reservations#index"
    get "confermata", to: "reservations#confirmation", as: :confirmation
    resources :groups, only: [], path: "gruppi" do
      resource :reservation, only: %i[new create]
    end
  end

  mount LetterThief::Engine => "/letter_thief" if Rails.env.development?

  # Protected by the app's session authentication via Mission Control's default
  # base controller (::ApplicationController, which requires a logged-in manager).
  mount MissionControl::Jobs::Engine, at: "/jobs"

  root "events#index"
end
