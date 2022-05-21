class LitresBook < ApplicationRecord
#after_create_commit { broadcast_append_to('log', partial: 'parse_tasks/log', locals: { header: "Litres.ru", info: "Book added to db: #{self.name}", url: "Db" }, target: "log") }


	def self.to_csv
		attributes = %w{name author series}

		CSV.generate(headers: true) do |csv|
			csv << attributes

			all.each do |litres_book|
				csv << litres_book.attributes.values_at(*attributes)
			end
		end
	end
end
