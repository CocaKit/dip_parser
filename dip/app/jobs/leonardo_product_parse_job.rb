class ParseJob < ApplicationJob
	queue_as :myjob


	def perform(parse_task, site_id)
	end

	def parse_category(source_url)
		html_origin = Nokogiri::HTML(Curl.get(source_url).body_str)
		category_name = html_origin.xpath("//h1[@class='singlepagetitle']/text()").to_s
		LitresBook.destroy_by(category_name: category_name)

		pages_html = get_pages_html(source_url)
		for i in pages_html
			book_htmls, book_urls = get_book_htmls_urls(i)
			book_hash_array = get_parsed_page_hash_array(book_htmls, book_urls, main_genre)
			LitresBook.create(book_hash_array)
		end
	end

	def get_pages_html(source_url)
		html_origin = Nokogiri::HTML(Curl.get(source_url).body_str)
		page_count = html_origin.xpath("//div[@class='pagination']/a[last()-1]/text()").to_s.to_i
		htmls_array = [html_origin]

		for page in 2...page_count+1 do
			htmls_array.push(Nokogiri::HTML(Curl.get("https://leonardohobby.by/ishop/tree_3779052909/?pages=#{page}").body_str))
			puts "Page #{page} parsed"
			sleep(rand(3))
		end
		return htmls_array
	end

	def write_log(msg)
		Turbo::StreamsChannel.broadcast_append_to("log", partial: "parse_tasks/log", locals: { log: msg }, target: "log") 
	end
end
