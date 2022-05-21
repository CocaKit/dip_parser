class HomeController < ApplicationController
	def index
		@litres_genres = LitresBook.distinct.pluck(:main_genre) 
		@leonardo_categories = LeonardoProduct.distinct.pluck(:category_name) 

		@litres_genres_and_count = []
		@litres_genres.each do | genre |
			@litres_genres_and_count.push({ name: genre, count: LitresBook.where(main_genre: genre).length })
		end

		@leonardo_categories_and_count = []
		@leonardo_categories.each do | category |
			@leonardo_categories_and_count.push({ name: category, count: LeonardoProduct.where(category_name: category).length })
		end
	end
end
