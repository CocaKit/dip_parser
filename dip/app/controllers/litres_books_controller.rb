class LitresBooksController < ApplicationController
	def index
	end

	def parse
		@books = LitresBook.all
		if not Rails.application.config.job_running
			LitresBookParseJob.perform_later "https://www.litres.ru/knigi-fantastika/geroicheskaya/"
		end
	end

	def log
		render :partial => "log"
	end

	def delete
	end

end
