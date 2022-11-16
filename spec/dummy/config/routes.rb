Rails.application.routes.draw do
  mount WebhookEvent::Engine => "/webhooks"

  root to: "welcome#index", as: :welcome
end