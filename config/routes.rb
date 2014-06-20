RailsDynamicErrors::Engine.routes.draw do
  match '*code', to: 'errors#show', via: :all
end
