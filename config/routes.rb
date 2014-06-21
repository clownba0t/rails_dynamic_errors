RailsDynamicErrors::Engine.routes.draw do
  match '*code', to: 'rails_dynamic_errors/errors#show', via: :all
end
