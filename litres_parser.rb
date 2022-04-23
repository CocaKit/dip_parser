#!/usr/bin/env ruby

require 'nokogiri'
require 'curb'

class Litres_book_parser
	def initialize(source_url)
		begin
			@source_url = source_url
			@html_origin = Nokogiri::HTML(Curl.get(@source_url).body_str)
		rescue
			error_to_file "Wrong url {#{source_url}}"
			abort
		end
		get_values
	end

	def get_values
		book_name = @html_origin.xpath("//div[@class='biblio_book_name biblio-book__title-block']/h1/text()")
		author = @html_origin.xpath("//div[@class='biblio_book_author']/a/span/text()")
		series = @html_origin.xpath("//div[@class='biblio_book_sequences']/span/a/text()")
		grade_litres = @html_origin.xpath("//div[@class='art-rating-unit rating-source-litres rating-popup-launcher']/div/div[@class='rating-number bottomline-rating']/text()")
		grade_livlib = @html_origin.xpath("//div[@class='art-rating-unit rating-source-livelib rating-popup-launcher']/div/div[@class='rating-number bottomline-rating']/text()")
		evaluators_litres = @html_origin.xpath("//div[@class='art-rating-unit rating-source-litres rating-popup-launcher']/div/div[@class='votes-count bottomline-rating-count']/text()")
		evaluators_livelib = @html_origin.xpath("//div[@class='art-rating-unit rating-source-livelib rating-popup-launcher']/div/div[@class='votes-count bottomline-rating-count']/text()")
		genres_first = @html_origin.xpath("//div[@class='biblio_book_info']/ul/li[2]/a/span/text()")
		genres_last = @html_origin.xpath("//div[@class='biblio_book_info']/ul/li[2]/a/text()")
		tags_first = @html_origin.xpath("//div[@class='biblio_book_info']/ul/li[3]/a/span/text()")
		tags_last = @html_origin.xpath("//div[@class='biblio_book_info']/ul/li[3]/a/text()")
		age_limit = @html_origin.xpath("//div[@class='biblio_book_info_detailed']/div/ul[@class='biblio_book_info_detailed_left']/li[1]/text()")
		age_limit = @html_origin.xpath("//div[@class='biblio_book_info_detailed']/div/ul[@class='biblio_book_info_detailed_left']/li[1]/text()")
		release_website = @html_origin.xpath("//div[@class='biblio_book_info_detailed']/div/ul[@class='biblio_book_info_detailed_left']/li[2]/text()")
		release_world = @html_origin.xpath("//div[@class='biblio_book_info_detailed']/div/ul[@class='biblio_book_info_detailed_left']/li[3]/text()")
		book_size = @html_origin.xpath("//div[@class='biblio_book_info_detailed']/div/ul[@class='biblio_book_info_detailed_left']/li[4]/text()")
		copyright = @html_origin.xpath("//div[@class='biblio_book_info_detailed']/div/ul[@class='biblio_book_info_detailed_right']/li[1]/text()")
		book_format = @html_origin.xpath("//div[@class='biblio_book_name biblio-book__title-block']/span/text()")
		book_price = @html_origin.xpath("//button[@class='coolbtn a_buyany btn-green']/span[@class='simple-price']/text()")
		puts book_name.to_s
		puts author.to_s
		puts series.to_s
		puts grade_litres.to_s.to_i
		puts grade_livlib.to_s.to_i
		puts evaluators_litres.to_s.to_i
		puts evaluators_livelib.to_s.to_i
		puts form_array(genres_first, genres_last)
		puts form_array(tags_first, tags_last)
		puts age_limit.to_s.strip
		puts release_website.to_s.strip
		puts release_world.to_s.strip
		puts book_size.to_s.strip
		puts copyright.to_s.strip
		puts book_format.to_s
		puts book_price
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
end

class Litres_catalog_parser
	def initialize(source_url)
		begin
			@source_url = source_url
			@html_origin = Nokogiri::HTML(Curl.get(@source_url).body_str)
		rescue
			error_to_file "Wrong url {#{source_url}}"
			abort
		end
		get_url_books
	end

	def get_url_books
		books_urls = @html_origin.xpath("//div[@class='art__name']/a/@href")
		puts books_urls
	end
end

if ARGV.length != 1
	abort("USAGE: ruby main.rb URL")
end

#parser = Litres_book_parser.new(ARGV[0])
parser = Litres_catalog_parser.new(ARGV[0])
