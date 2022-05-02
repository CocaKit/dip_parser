Rails.application.routes.draw do
	resources :parse_tasks do
		member do
			put 'parse'
		end
	end


	get 'litres_books/index'
	get 'litres_books/delete'
	get 'litres_books/log'
	get 'litres_books/parse'

	root "parse_tasks#index"
end

