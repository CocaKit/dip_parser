class LeonardoProduct < ApplicationRecord
#after_create_commit { broadcast_append_to('log', partial: 'parse_tasks/log', locals: { header: "Leonardo.by", info: "Product added to db: #{self.name}", url: "Db" }, target: "log") }

	def self.to_csv
		attributes = %w{name brend price}

		CSV.generate(headers: true) do |csv|
			csv << attributes

			all.each do |litres_book|
				csv << litres_book.attributes.values_at(*attributes)
			end
		end
	end
end
