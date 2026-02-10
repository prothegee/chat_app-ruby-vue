Rails.application.routes.draw do
  # note:
  # - for somehow this is standard naming for websocket:
  #   - https://guides.rubyonrails.org/action_cable_overview.html
  mount ActionCable.server => "/cable"

  namespace :api do
    namespace :v1 do
      # rest api status; test
      resources :status, only: [:index]

      # Tetap pertahankan REST untuk room management
      # rest api for chat
      get  "/chat",               to: "chat#index"
      post "/chat",               to: "chat#create"
      get  "/chat/:name/messages", to: "chat#messages"
    end
  end
end
