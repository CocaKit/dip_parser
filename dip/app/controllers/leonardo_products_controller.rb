class LeonardoProductsController < ApplicationController
	before_action :set_leonardo_products, only: %i[ show ]
	before_action :set_leonardo_products_from_params, only: %i[ search ]
	before_action :set_leonardo_products_from_session, only: %i[ index page export ]

	def index
		@page = session[:leonardo_current_page]
		if not @page.nil?
			@leonardo_products = @leonardo_products.limit(10).offset(10 * (@page - 1))
		end
		respond_to do |format|
			format.html
		end
	end

	def show
	end

	def search
		session[:leonardo_current_page] = 1
		respond_to do |format|
			format.turbo_stream do
				render turbo_stream: [
					turbo_stream.update("leonardo_products", partial: "leonardo_products/list", locals: { leonardo_products: @leonardo_products, page_num: 1 }, target: "leonardo_products") ]
			end
		end
	end

	def page
		page = params[:id].to_i
		session[:leonardo_current_page] = page
		@leonardo_products = @leonardo_products.limit(10).offset(10 * (page - 1))
		respond_to do |format|
			if page != 0 and @leonardo_products.length != 0
				format.turbo_stream { render turbo_stream: turbo_stream.update("leonardo_products", partial: "leonardo_products/list", locals: { leonardo_products: @leonardo_products, page_num: page }, target: "leonardo_products") }
			else 
				format.turbo_stream
			end
		end
	end

	def export
		respond_to do |format|
			if not atr.nil?
				format.csv { send_data @leonardo_products.to_csv, filename: "leonardo-products.csv" }
			else
				format.html { redirect_to leonardo_products_url, alert: "Export failed: do a search first" }
			end
		end
	end 
	private

	def set_leonardo_products
		@leonardo_product = LeonardoProduct.find(params[:id])
	end

	def set_leonardo_products_from_session
		atr = session[:leonardo_searched_products]
		if not atr.nil?
			@leonardo_products = LeonardoProduct.where("name ILIKE ? AND brend ILIKE ? AND rating >= ? AND rating <= ? AND evaluators >= ? AND evaluators <= ? AND price >= ? AND price <= ? AND instock = ?", "%#{atr["name"]}%", "%#{atr["brend"]}%", atr["min_rating"], atr["max_rating"], atr["min_count_of_evaluators"], atr["max_count_of_evaluators"], atr["min_price"], atr["max_price"], get_instock(atr["in_stock"]))
			@leonardo_products = @leonardo_products.order(atr["order"])
		end
	end

	def set_leonardo_products_from_params
		@leonardo_products = LeonardoProduct.where("name ILIKE ? AND brend ILIKE ? AND rating >= ? AND rating <= ? AND evaluators >= ? AND evaluators <= ? AND price >= ? AND price <= ? AND instock = ?", "%#{params[:name]}%", "%#{params[:brend]}%", params[:min_rating], params[:max_rating], params[:min_count_of_evaluators], params[:max_count_of_evaluators], params[:min_price], params[:max_price], get_instock(params[:in_stock])).limit(10)
		@leonardo_products = @leonardo_products.order(params[:order])
		session[:leonardo_searched_products] = params
	end

	def get_instock(stock)
		return stock.nil?
	end
end
