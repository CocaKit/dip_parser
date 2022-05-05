class LitresBooksController < ApplicationController
	before_action :set_litres_book, only: %i[ show ]
	def index
		@litres_books = LitresBook.all
	end

	def show
	end

	def search
		@litres_books = LitresBook.where("name ILIKE ? AND author ILIKE ? AND series ILIKE ? AND grade_litres >= ? AND grade_litres <= ? AND evaluators_litres >= ? AND evaluators_litres <= ?", "%#{params[:name]}%", "%#{params[:author]}%", "%#{params[:series]}%", params[:min_litres_grade], params[:max_litres_grade], params[:min_litres_count_of_evaluators], params[:max_litres_count_of_evaluators]).limit(10)
		session[:searched_books] = params
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
		atr = session[:searched_books]
		@litres_books = LitresBook.where("name ILIKE ? AND author ILIKE ? AND series ILIKE ? AND grade_litres >= ? AND grade_litres <= ? AND evaluators_litres >= ? AND evaluators_litres <= ?", "%#{atr["name"]}%", "%#{atr["author"]}%", "%#{atr["series"]}%", atr["min_litres_grade"], atr["max_litres_grade"], atr["min_litres_count_of_evaluators"], atr["max_litres_count_of_evaluators"]).limit(10).offset(10 * page)
		puts "TEST"
		respond_to do |format|
			format.turbo_stream { render turbo_stream: turbo_stream.replace("litres_books_page", partial: "litres_books/list", locals: { litres_books: @litres_books, page_num: page+1 }, target: "litres_books_page") }
		end
	end

	def export
		atr = session[:searched_books]
		@litres_books = LitresBook.where("name ILIKE ? AND author ILIKE ? AND series ILIKE ? AND grade_litres >= ? AND grade_litres <= ? AND evaluators_litres >= ? AND evaluators_litres <= ?", "%#{atr["name"]}%", "%#{atr["author"]}%", "%#{atr["series"]}%", atr["min_litres_grade"], atr["max_litres_grade"], atr["min_litres_count_of_evaluators"], atr["max_litres_count_of_evaluators"])
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

end
