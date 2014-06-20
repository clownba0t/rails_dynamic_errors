RailsDynamicErrors::Engine.routes.draw do
  match '/404', to: 'errors#show', via: :all
end
