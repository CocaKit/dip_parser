class LitresBooksController < ApplicationController
	before_action :set_litres_book, only: %i[ show ]
	before_action :set_litres_books_from_params, only: %i[ search ]
	before_action :set_litres_books_from_session, only: %i[ index page export ]

	def index
		@page = session[:current_page]
		if not @page.nil?
			@litres_books = @litres_books.limit(10).offset(10 * (@page - 1))
		end
		respond_to do |format|
			format.html
		end
	end

	def show
	end

	def search
		respond_to do |format|
			format.turbo_stream do
				render turbo_stream: [
					turbo_stream.update("search_form", partial: "litres_books/form", target: "search_form"),
					turbo_stream.update("litres_books", partial: "litres_books/list", locals: { litres_books: @litres_books, page_num: 1 }, target: "litres_books") ]
			end
		end
	end

	def page
		page = params[:id].to_i
		session[:current_page] = page
		@litres_books = @litres_books.limit(10).offset(10 * (page - 1))
		respond_to do |format|
			if page != 0 and @litres_books.length != 0
				format.turbo_stream { render turbo_stream: turbo_stream.update("litres_books", partial: "litres_books/list", locals: { litres_books: @litres_books, page_num: page }, target: "litres_books") }
			else 
				format.turbo_stream
			end
		end
	end

	def export
		respond_to do |format|
			if not atr.nil?
				format.csv { send_data @litres_books.to_csv, filename: "litres-books.csv" }
			else
				format.html { redirect_to litres_books_url, alert: "Export failed: do a search first" }
			end
		end
	end

	private

	def set_litres_book
		@litres_book = LitresBook.find(params[:id])
	end

	def sort_tags_genres(litres_books, searched_str)
		for request in searched_str.split(',')
			request = request.strip
			litres_books = litres_books.where("ARRAY_TO_STRING(genres, ',') ILIKE ? OR ARRAY_TO_STRING(tags, ',') ILIKE ?", "%#{request}%", "%#{request}%")
		end

		return litres_books
	end

	def set_litres_books_from_session
		atr = session[:searched_books]
		if not atr.nil?
			@litres_books = LitresBook.where("name ILIKE ? AND author ILIKE ? AND series ILIKE ? AND grade_litres >= ? AND grade_litres <= ? AND evaluators_litres >= ? AND evaluators_litres <= ? AND price >= ? AND price <= ?", "%#{atr["name"]}%", "%#{atr["author"]}%", "%#{atr["series"]}%", atr["min_litres_grade"], atr["max_litres_grade"], atr["min_litres_count_of_evaluators"], atr["max_litres_count_of_evaluators"], atr["min_price"], atr["max_price"])
			@litres_books = sort_tags_genres(@litres_books, atr["tags_genres"])
		end
	end

	def set_litres_books_from_params
		@litres_books = LitresBook.where("name ILIKE ? AND author ILIKE ? AND series ILIKE ? AND grade_litres >= ? AND grade_litres <= ? AND evaluators_litres >= ? AND evaluators_litres <= ? AND price >= ? AND price <= ?", "%#{params[:name]}%", "%#{params[:author]}%", "%#{params[:series]}%", params[:min_litres_grade], params[:max_litres_grade], params[:min_litres_count_of_evaluators], params[:max_litres_count_of_evaluators], params[:min_price], params[:max_price]).limit(10)
		@litres_books = sort_tags_genres(@litres_books, params[:tags_genres])
		session[:searched_books] = params
	end

end
