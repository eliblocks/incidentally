Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "incidents#index"

  namespace :webhooks do
    post "/slack/declare", to: "slack#declare"
    post "/slack/resolve", to: "slack#resolve"
    post "/slack/interact", to: "slack#interact"
  end
end
