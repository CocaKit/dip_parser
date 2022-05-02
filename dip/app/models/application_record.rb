class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
	Rails.application.config.job_running = false
end
