WebhookEvent::Engine.routes.draw do
  post "event", to: "webhook#event"
end
