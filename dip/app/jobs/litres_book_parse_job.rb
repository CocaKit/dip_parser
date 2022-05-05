class LitresBookParseJob < ApplicationJob
	queue_as :myjob


	def perform(source_urls, parse_task)
		for source_url in source_urls
			parse_category(source_url)
		end
		parse_task.update(status: 3, finish_date: DateTime.now)
	end

	private

	def get_book_info(html_origin)

		book_name = html_origin.xpath("//div[@class='biblio_book_name biblio-book__title-block']/h1/text()").to_s
		author = html_origin.xpath("//div[@class='biblio_book_author']/a/span/text()").to_s
		series = html_origin.xpath("//div[@class='biblio_book_sequences']/span/a/text()").to_s
		grade_litres = html_origin.xpath("//div[@class='art-rating-unit rating-source-litres rating-popup-launcher']/div/div[@class='rating-number bottomline-rating']/text()").to_s.sub(",", ".").to_f
		grade_livelib = html_origin.xpath("//div[@class='art-rating-unit rating-source-livelib rating-popup-launcher']/div/div[@class='rating-number bottomline-rating']/text()").to_s.sub(",", ".").to_f
		evaluators_litres = html_origin.xpath("//div[@class='art-rating-unit rating-source-litres rating-popup-launcher']/div/div[@class='votes-count bottomline-rating-count']/text()").to_s.to_i
		evaluators_livelib = html_origin.xpath("//div[@class='art-rating-unit rating-source-livelib rating-popup-launcher']/div/div[@class='votes-count bottomline-rating-count']/text()").to_s.to_i
		genres_first = html_origin.xpath("//div[@class='biblio_book_info']/ul/li[2]/a/span/text()")
		genres_last = html_origin.xpath("//div[@class='biblio_book_info']/ul/li[2]/a/text()")
		genres = form_array(genres_first, genres_last)
		tags_first = html_origin.xpath("//div[@class='biblio_book_info']/ul/li[3]/a/span/text()")
		tags_last = html_origin.xpath("//div[@class='biblio_book_info']/ul/li[3]/a/text()")
		tags = form_array(tags_first, tags_last)
		age_limit = html_origin.xpath("//div[@class='biblio_book_info_detailed']/div/ul[@class='biblio_book_info_detailed_left']/li/strong[text()='Возрастное ограничение:']/../text()").to_s.strip.split('+')[0].to_i
		release_website = html_origin.xpath("//div[@class='biblio_book_info_detailed']/div/ul[@class='biblio_book_info_detailed_left']/li/strong[text()='Дата выхода на ЛитРес:']/../text()").to_s.strip.split[2].to_i
		release_translate = html_origin.xpath("//div[@class='biblio_book_info_detailed']/div/ul[@class='biblio_book_info_detailed_left']/li/strong[text()='Дата перевода:']/../text()").to_s.strip.to_i
		release_world = html_origin.xpath("//div[@class='biblio_book_info_detailed']/div/ul[@class='biblio_book_info_detailed_left']/li/strong[text()='Дата написания:']/../text()").to_s.strip.to_i
		book_size = html_origin.xpath("//div[@class='biblio_book_info_detailed']/div/ul[@class='biblio_book_info_detailed_left']/li/strong[text()='Объем:']/../text()").to_s.strip.split[0]
		isbn = html_origin.xpath("//div[@class='biblio_book_info_detailed']/div/ul[@class='biblio_book_info_detailed_right']/li/strong[text()='ISBN:']/../span/text()").to_s.strip
		book_price = html_origin.xpath("//button[@class='coolbtn a_buyany btn-green']/span[@class='simple-price']/text()").to_s.to_i
		book_description = html_origin.xpath("//div[@class='biblio_book_descr_publishers']/p/text()").to_s
		book_img = html_origin.xpath("//div[@class='cover']//img/@src").to_s

		return book_name, author, series, grade_litres, grade_litres, grade_livelib, evaluators_litres, evaluators_livelib, genres, tags, age_limit, release_website, release_world, release_translate, book_size, isbn, book_price, book_description, book_img
	end
	
	def console_output(book_name, author, series, grade_litres, grade_livelib, evaluators_litres, evaluators_livelib, genres, tags, age_limit, release_website, release_world, release_translate, book_size, isbn, book_price, book_description, source_url)
		puts "URL: " + source_url
		puts "Name: " + book_name
		puts "Author: " + author
		puts "Series: " + series
		puts "Litres grade: " + grade_litres.to_s
		puts "Livelib grade: " + grade_livelib.to_s
		puts "Litres evaluators count: " + evaluators_litres.to_s
		puts "Livelib evaluators count: " + evaluators_livelib.to_s
		puts "Age limit: " + age_limit.to_s
		puts "Release on website: " + release_website.to_s
		puts "Release on world: " + release_world.to_s
		puts "Translate release: " + release_translate.to_s
		puts "Size: " + book_size
		puts "Isbn: " + isbn
		puts "Price: " + book_price.to_s
		puts "Description: " + book_description
		puts "Genres:"
		puts genres
		puts "Tags:"
		puts tags
	end

	def form_array(first_arr, last_arr)
		count = 0
		full_arr = []
		while count < first_arr.length do
			full_arr.push(first_arr[count].to_s.upcase + last_arr[count].to_s)
			count += 1
		end

		return full_arr
	end

	def check_book_format(html_origin)
		book_format = html_origin.xpath("//div[@class='biblio_book_name biblio-book__title-block']/span/text()").to_s

		return book_format
	end

	def parse_category(source_url)
		html_origin = Nokogiri::HTML(Curl.get(source_url).body_str)
		main_genre = html_origin.xpath("//h1[@itemprop='about']/text()").to_s
		LitresBook.destroy_by(main_genre: main_genre)

		pages_html = get_pages_html(source_url)
		for i in pages_html
			book_htmls, book_urls = get_book_htmls_urls(i)
			book_hash_array = get_parsed_page_hash_array(book_htmls, book_urls, main_genre)
			LitresBook.create(book_hash_array)
		end

	end

	def get_pages_html(source_url)
		html_origin = Nokogiri::HTML(Curl.get(source_url).body_str)
		items_count = html_origin.xpath("//div[@class='Header-module__mainSection']")
		page_num = 2
		pages_html = [html_origin]
		new_page_html =  Nokogiri::HTML(Curl.get("#{source_url}page-#{page_num}/").body_str)
		until new_page_html.xpath("//div[@class='Header-module__mainSection']").empty? do
			puts ":::Page #{page_num} found:::"
			write_log("Found page on #{source_url}: #{page_num}") 
			pages_html.push(new_page_html)
			page_num += 1
			new_page_html =  Nokogiri::HTML(Curl.get("#{source_url}page-#{page_num}/").body_str)
			sleep(rand(3))
		end

		return pages_html
	end

	def get_parsed_page_hash_array(book_htmls, book_urls, main_genre)
		hash_array = []
		for i in 0...book_htmls.length
			if check_book_format(book_htmls[i]) == "Текст"
				book_name, author, series, grade_litres, grade_litres, grade_livelib, evaluators_litres, evaluators_livelib, genres, tags, age_limit, release_website, release_world, release_translate, book_size, isbn, book_price, book_description, book_img = get_book_info(book_htmls[i])
				write_log("Book parsed: #{book_name}")
				hash_array.push( { main_genre: main_genre, name: book_name, author: author, series: series, grade_litres: grade_litres, grade_livelib: grade_livelib, evaluators_litres: evaluators_litres, evaluators_livelib: evaluators_livelib, genres: genres, tags: tags, age_limit: age_limit, release_on_website: release_website, release_on_world: release_world, release_translate: release_translate, book_size: book_size, isbn: isbn, price: book_price, description: book_description, page_url: book_urls[i], img: book_img } )
			end
		end

		return hash_array
	end

	def get_book_htmls_urls(html_origin)
		book_part_urls = html_origin.xpath("//div[@class='art__name']/a/@href")
		book_htmls = []
		book_urls = []
		for i in book_part_urls
			book_full_url = "https://www.litres.ru#{i}"
			book_urls.push(book_full_url)
			book_htmls.push(Nokogiri::HTML(Curl.get(book_full_url).body_str))
			write_log("Found url: https://www.litres.ru#{i}")
			sleep(rand(3))
		end

		return book_htmls, book_urls
	end

	def write_log(msg)
		Turbo::StreamsChannel.broadcast_append_to("log", partial: "parse_tasks/log", locals: { log: msg }, target: "log") 
	end
end
