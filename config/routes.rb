Rails.application.routes.draw do
  devise_for :users
  resources :overtime_work_infos
end
