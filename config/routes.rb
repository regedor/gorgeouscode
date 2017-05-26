Rails.application.routes.draw do
  root "projects#index"

  resources :projects, only: [:index, :create, :destroy]

  get "github/:name" => "github_accounts#show"

  get "github/:github_owner/:github_name" => "reports#show_last_report",
      as: "show_last_report",
      constraints: { github_name: %r{[^\/]+} }
  get "github/:github_owner/:github_name/model-overview/" => "model_overview#show_last_report_model_overview",
      as: "show_last_report_model_overview",
      constraints: { github_name: %r{[^\/]+} }

  scope "/hooks", controller: :hooks do
    post :github_event
  end
end
