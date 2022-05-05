#!/usr/bin/env ruby

require 'nokogiri'
require 'curb'

html_origin = Nokogiri::HTML(Curl.get("https://www.litres.ru/sergey-lukyanenko/mesyac-za-rubikonom/").body_str)
book_img = html_origin.xpath("//div[@class='cover']//img/@src").to_s
puts book_img
