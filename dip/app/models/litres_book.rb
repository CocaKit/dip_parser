class LitresBook < ApplicationRecord
	after_create_commit { broadcast_append_to('log', partial: 'litres_books/log', locals: { log: "Book added to db: #{self.name}" }, target: "log") }

end
