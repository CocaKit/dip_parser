Rails.application.routes.draw do
	resources :parse_tasks do
		member do
			put 'parse'
		end
	end

	resources :litres_books, only: [:index, :show] do
		collection do
			post 'search'
			post 'export'
		end
		member do
			post 'page'
		end
	end

	root "parse_tasks#index"
end

