class ParseJob < ApplicationJob
	queue_as :myjob

	@@log_array = []
	@@log_max_count = 5
	@@log_text = ""


	def perform(parse_task)
		puts parse_task.web_site
		if not parse_task.nil? and not parse_task.web_site.nil? and parse_task.web_site >= 1 and parse_task.web_site <= 2 and ParseTask.find_by(web_site: parse_task.web_site, status: 2).nil?
			parse_task.update(status: 2)
			for source_url in parse_task.page_urls
				if parse_task.web_site == 1
					parse_litres_category(source_url)
				elsif parse_task.web_site = 2
					parse_leonardo_category(source_url)
				end
			end
			parse_task.update(status: 3, finish_date: DateTime.now, logs: @@log_text)
		end
	end

	private

	def get_litres_book_info(html_origin)
		book_name = html_origin.xpath("//div[@class='biblio_book_name biblio-book__title-block']/h1/text()").to_s
		author = html_origin.xpath("//div[@class='biblio_book_author']/a/span/text()").to_s
		series = html_origin.xpath("//div[@class='biblio_book_sequences']/span/a/text()").to_s
		grade_litres = html_origin.xpath("//div[@class='art-rating-unit rating-source-litres rating-popup-launcher']/div/div[@class='rating-number bottomline-rating']/text()").to_s.sub(",", ".").to_f
		grade_livelib = html_origin.xpath("//div[@class='art-rating-unit rating-source-livelib rating-popup-launcher']/div/div[@class='rating-number bottomline-rating']/text()").to_s.sub(",", ".").to_f
		evaluators_litres = html_origin.xpath("//div[@class='art-rating-unit rating-source-litres rating-popup-launcher']/div/div[@class='votes-count bottomline-rating-count']/text()").to_s.to_i
		evaluators_livelib = html_origin.xpath("//div[@class='art-rating-unit rating-source-livelib rating-popup-launcher']/div/div[@class='votes-count bottomline-rating-count']/text()").to_s.to_i
		genres_first = html_origin.xpath("//div[@class='biblio_book_info']/ul/li[2]/a/span/text()")
		genres_last = html_origin.xpath("//div[@class='biblio_book_info']/ul/li[2]/a/text()")
		genres = form_litres_array(genres_first, genres_last)
		tags_first = html_origin.xpath("//div[@class='biblio_book_info']/ul/li[3]/a/span/text()")
		tags_last = html_origin.xpath("//div[@class='biblio_book_info']/ul/li[3]/a/text()")
		tags = form_litres_array(tags_first, tags_last)
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

	def form_litres_array(first_arr, last_arr)
		count = 0
		full_arr = []
		while count < first_arr.length do
			full_arr.push(first_arr[count].to_s.upcase + last_arr[count].to_s)
			count += 1
		end

		return full_arr
	end

	def check_litres_book_format(html_origin)
		book_format = html_origin.xpath("//div[@class='biblio_book_name biblio-book__title-block']/span/text()").to_s

		return book_format
	end

	def parse_litres_category(source_url)
		html_origin = Nokogiri::HTML(Curl.get(source_url).body_str)
		main_genre = html_origin.xpath("//h1[@itemprop='about']/text()").to_s
		LitresBook.destroy_by(main_genre: main_genre)
		write_log("Litres.ru", "Parse category #{main_genre}", source_url) 

		pages_html = get_litres_pages_html(source_url)
		for i in pages_html
			book_htmls, book_urls = get_litres_book_htmls_urls(i)
			book_hash_array = get_parsed_litres_page_hash_array(book_htmls, book_urls, main_genre)
			LitresBook.create(book_hash_array)
		end
	end

	def get_litres_pages_html(source_url)
		html_origin = Nokogiri::HTML(Curl.get(source_url).body_str)
		items_count = html_origin.xpath("//div[@class='Header-module__mainSection']")
		page_num = 2
		pages_html = [html_origin]
		new_page_html =  Nokogiri::HTML(Curl.get("#{source_url}page-#{page_num}/").body_str)
		until new_page_html.xpath("//div[@class='Header-module__mainSection']").empty? do
			write_log("Litres.ru", "Found page num #{page_num}", "#{source_url}page-#{page_num}/") 
			pages_html.push(new_page_html)
			page_num += 1
			new_page_html =  Nokogiri::HTML(Curl.get("#{source_url}page-#{page_num}/").body_str)
			sleep(rand(3))
		end

		return pages_html
	end

	def get_parsed_litres_page_hash_array(book_htmls, book_urls, main_genre)
		hash_array = []
		for i in 0...book_htmls.length
			if check_litres_book_format(book_htmls[i]) == "Текст"
				book_name, author, series, grade_litres, grade_litres, grade_livelib, evaluators_litres, evaluators_livelib, genres, tags, age_limit, release_website, release_world, release_translate, book_size, isbn, book_price, book_description, book_img = get_litres_book_info(book_htmls[i])
				write_log("Litres.ru", "Book parsed: #{book_name}", book_urls[i])
				hash_array.push( { main_genre: main_genre, name: book_name, author: author, series: series, grade_litres: grade_litres, grade_livelib: grade_livelib, evaluators_litres: evaluators_litres, evaluators_livelib: evaluators_livelib, genres: genres, tags: tags, age_limit: age_limit, release_on_website: release_website, release_on_world: release_world, release_translate: release_translate, book_size: book_size, isbn: isbn, price: book_price, description: book_description, page_url: book_urls[i], img: book_img } )
			end
		end

		return hash_array
	end

	def get_litres_book_htmls_urls(html_origin)
		book_part_urls = html_origin.xpath("//div[@class='art__name']/a/@href")
		book_htmls = []
		book_urls = []
		for i in book_part_urls
			book_full_url = "https://www.litres.ru#{i}"
			book_urls.push(book_full_url)
			book_htmls.push(Nokogiri::HTML(Curl.get(book_full_url).body_str))
			write_log("Litres.ru", "Found url", "https://www.litres.ru#{i}")
			sleep(rand(3))
		end

		return book_htmls, book_urls
	end

	def parse_leonardo_category(source_url)
		html_origin = Nokogiri::HTML(Curl.get(source_url).body_str)
		category_name = html_origin.xpath("//h1[@class='singlepagetitle']/text()").to_s.encode("UTF-8","cp1251").strip
		LeonardoProduct.destroy_by(category_name: category_name)
		write_log("Leonardo.by", "Parse category #{category_name}", source_url) 

		pages_html = get_leonardo_pages_html(source_url)
		for i in pages_html
			book_htmls, book_urls = get_leonardo_produtct_htmls_urls(i)
			book_hash_array = get_leonardo_parsed_page_hash_array(book_htmls, book_urls, category_name)
			LeonardoProduct.create(book_hash_array)
		end
	end

	def get_leonardo_pages_html(source_url)
		html_origin = Nokogiri::HTML(Curl.get(source_url).body_str)
		page_count = html_origin.xpath("//div[@class='pagination']/a[last()-1]/text()").to_s.to_i
		htmls_array = [html_origin]

		for page in 2...page_count+1 do
			full_url = "#{source_url}?pages=#{page}"
			htmls_array.push(Nokogiri::HTML(Curl.get(full_url).body_str))
			write_log("Leonardo.by", "Found page number #{page}", full_url) 
			sleep(rand(3))
		end

		return htmls_array
	end

	def get_leonardo_produtct_htmls_urls(html_origin)
		product_links = html_origin.xpath("//div[@class='product-title']/a/@href")
		product_htmls = []
		product_urls = []
		for i in product_links do
			product_full_url = "https://leonardohobby.by#{i}"
			product_urls.push(product_full_url)
			product_htmls.push(Nokogiri::HTML(Curl.get(product_full_url).body_str))
			write_log("Leonardo.by", "Found url", product_full_url)
			sleep(rand(3))
		end

		return product_htmls, product_urls
	end

	def get_leonardo_parsed_page_hash_array(product_htmls, product_urls, product_category)
		hash_array = []
		for i in 0...product_htmls.length
			name, brend, price, img, is_instock, rating, evaluators_count, desc = get_leonardo_produtct_info(product_htmls[i])
			write_log("Leonardo.by", "Product parsed: #{name}", product_urls[i])
			hash_array.push( {category_name: product_category, name: name, brend: brend, price: price, img: img, instock: is_instock, rating: rating, evaluators: evaluators_count, desc: desc, source_url: product_urls[i]} )
		end

		return hash_array
	end

	def get_leonardo_produtct_info(html_origin)
		product_name = html_origin.xpath("//div[@class='product-title']/h1/text()").to_s.encode("UTF-8","cp1251").strip
		product_brend = html_origin.xpath("//div[@class='brand-manufacturer-snippet']/span/a/text()").to_s.encode("UTF-8","cp1251").strip
		product_price = html_origin.xpath("//div[@class='actual-price']/text()").to_s.encode("UTF-8","cp1251").split[0].strip
		product_img = html_origin.xpath("//div[@class='bigitemimg']/div/a/@href").to_s
		product_is_instock = check_leonardo_stock(html_origin.xpath("//div[@class='status-display-item']/span[1]/@class").to_s)
		product_rating = get_leonardo_rating(html_origin.xpath("//div[@class='star__in']/@style"))
		product_evaluators_count = html_origin.xpath("//a[@aria-controls='reviews']/text()").to_s.encode("UTF-8","cp1251").strip.split[1][1...-1].to_i
		product_desc = html_origin.xpath("//div[@aria-labelledby='itemdesc-tab']/text()").to_s.encode("UTF-8","cp1251").strip
		return product_name, product_brend, product_price, product_img, product_is_instock, product_rating, product_evaluators_count, product_desc
	end

	def check_leonardo_stock(stock)
		if stock == "in-stock"
			return true
		else 
			return false 
		end
	end

	def get_leonardo_rating(stars)
		rating = 0
		for count in 0...stars.length
			rating += (stars[count].to_s.split[1][0...-2].to_f / 100)
		end

		return rating
	end

	def write_log(header, info, url)
		@@log_array.unshift({header: header, info: info, url: url})
		if @@log_array.length > @@log_max_count
			@@log_array.pop
		end

		@@log_text += "#{DateTime.now} - #{header} - #{info} - #{url}\n"
		Turbo::StreamsChannel.broadcast_update_to("log", partial: "parse_tasks/log", locals: { logs: @@log_array }, target: "log") 
	end
end
