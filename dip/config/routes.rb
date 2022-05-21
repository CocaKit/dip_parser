Rails.application.routes.draw do
	resources :parse_tasks do
		member do
			put 'parse'
			post 'export'
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

	resources :leonardo_products, only: [:index, :show] do
		collection do
			post 'search'
			post 'export'
		end
		member do
			post 'page'
		end
	end

	get 'home', to: "home#index"

	root "home#index"
end

