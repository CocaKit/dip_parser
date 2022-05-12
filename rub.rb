#!/usr/bin/env ruby

require 'nokogiri'
require 'curb'

def get_htmls_array(source_url)
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

def get_produtct_htmls_urls(html_origin)
	product_links = html_origin.xpath("//div[@class='product-title']/a/@href")
	product_htmls = []
	product_urls = []
	for i in product_links do
		product_full_url = "https://leonardohobby.by/#{i}"
		product_urls.push(product_full_url)
		product_htmls.push(Nokogiri::HTML(Curl.get(product_full_url).body_str))
#		write_log("Found url: #{product_full_url}")
		puts("Found url: #{product_full_url}")
		sleep(rand(3))
	end

	return product_htmls, product_urls
end

def get_produtct_info(html_origin)
	product_name = html_origin.xpath("//div[@class='product-title']/h1/text()").to_s.encode("UTF-8","cp1251").strip
	product_brend = html_origin.xpath("//div[@class='brand-manufacturer-snippet']/span/a/text()").to_s.encode("UTF-8","cp1251").strip
	product_price = html_origin.xpath("//div[@class='actual-price']/text()").to_s.split[0].encode("UTF-8","cp1251").strip
	product_img = html_origin.xpath("//div[@class='bigitemimg']/div/a/@href").to_s
	product_is_instock = check_stock(html_origin.xpath("//div[@class='status-display-item']/span[1]/@class").to_s)
	product_rating = get_rating(html_origin.xpath("//div[@class='star__in']/@style"))
	product_evaluators_count = html_origin.xpath("//a[@aria-controls='reviews']/text()").to_s.encode("UTF-8","cp1251").strip.split[1][1...-1].to_i
	product_desc = html_origin.xpath("//div[@aria-labelledby='itemdesc-tab']/text()").to_s.encode("UTF-8","cp1251").strip
	return product_name, product_brend, product_price, product_img, product_is_instock, product_rating, product_evaluators_count, product_desc
end

def check_stock(stock)
	if stock == "in-stock"
		return true
	else 
		return false 
	end
end

def get_rating(stars)
	rating = 0
	for count in 0...stars.length
		rating += (stars[count].to_s.split[1][0...-2].to_f / 100)
	end

	return rating
end

def get_parsed_page_hash_array(product_htmls, product_urls, product_category)
	hash_array = []
	for i in 0...product_htmls.length
		name, brend, price, img, is_instock, rating, evaluators_count, desc = get_produtct_info(product_htmls[i])
		hash_array.push( {category: category, name: name, price: price, img_url: url, is_instock: is_instock, rating: rating, evaluators_count: evaluators_count, desc: desc, source_url: source_url} )
	end

	return hash_array
end

source_url = "https://leonardohobby.by/ishop/good_13661621062/"
html_origin = Nokogiri::HTML(Curl.get(source_url).body_str)
get_produtct_info(html_origin)
