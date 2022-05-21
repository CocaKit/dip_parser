class ParseTask < ApplicationRecord
	validates :name, :status, :web_site, presence: true
	validates :status, inclusion: { in: [1,2,3], 
		message: "%{value} is not a valid size" }
	validates :web_site, inclusion: { in: [1, 2], 
		message: "%{value} is not a valid size" }
	validates :name, length: { in: 1..20, 
		wrong_length: "Length: from 1 to 20" }

	after_update_commit { broadcast_update_to('tasks', partial: 'parse_tasks/tasks', locals: { parse_tasks: ParseTask.all }, target: "tasks") }
end
