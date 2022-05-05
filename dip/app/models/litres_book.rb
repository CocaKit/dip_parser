class LitresBook < ApplicationRecord
	after_create_commit { broadcast_append_to('log', partial: 'parse_tasks/log', locals: { log: "Book added to db: #{self.name}" }, target: "log") }


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
