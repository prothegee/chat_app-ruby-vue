Rails.application.routes.draw do
  # note:
  # - for somehow this is standard naming for websocket:
  #   - https://guides.rubyonrails.org/action_cable_overview.html
  mount ActionCable.server => "/cable"

  # # in deployment `/base` is exists; why?
  # get "/base", to: redirect("/cable")
  # post "/base", to: redirect("/cable")
  # # match "/base", to: ActionCable.server, via: [:get, :post] # option but not sure

  namespace :api do
    namespace :v1 do
      # rest api status; test
      resources :status, only: [:index]

      # rest api for chat
      get  "/chat",                to: "chat#index"
      post "/chat",                to: "chat#create"
      get  "/chat/:name/messages", to: "chat#messages"
    end
  end
end
