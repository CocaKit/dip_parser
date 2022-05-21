class ParseTasksController < ApplicationController
	before_action :set_parse_task, only: %i[ show edit update destroy parse export ]
	before_action :set_task_info, only: %i[ create ]

	def index
		@parse_tasks = ParseTask.all
	end

	def show
	end

	def new
		@parse_task = ParseTask.new
	end

	def edit
		if @parse_task.status != 1
			redirect_to parse_tasks_url, alert: "Parse task is in progress or finished."
		end
	end

	def create
		@parse_task = ParseTask.new(name: @name, web_site: @web_site, status: 1)

		respond_to do |format| if @parse_task.save
				format.html { redirect_to parse_tasks_url, notice: "Parse task #{@parse_task.name} was successfully created." }
			else
				format.html { render :new, status: :unprocessable_entity }
			end
		end
	end

	def update
		@page_urls = []
		@category_names = []
		for line in params[:category]
			@page_urls.push(line.split(",")[0])
			@category_names.push(line.split(",")[1])
		end

		respond_to do |format|
			if @parse_task.update(category_names: @category_names, page_urls: @page_urls)
				format.html { redirect_to parse_tasks_url, notice: "Parse task #{@name} was successfully updated." }
			else
				format.html { render :edit, status: :unprocessable_entity }
			end
		end
	end

	def destroy
		respond_to do |format|
			if @parse_task.status != 2
				format.html { redirect_to parse_tasks_url, notice: "Parse task #{@parse_task.name}was successfully destroyed." }
				@parse_task.destroy
			else
				format.html { redirect_to parse_tasks_url, alert: "Cant delete, because parse task #{@parse_task.name} is in progress." }
			end
		end
	end

	def export
		respond_to do |format|
			logs_text = @parse_task.logs
			format.text { send_data logs_text, filename: "parse_tasks_log.txt", type: 'text; charset=UTF-8;' }
		end
	end

	def parse
		respond_to do |format|
			if check_running_job 
				format.html { redirect_to parse_tasks_url, alert: "Cant parse, because someone parse task is in progress." }
			elsif @parse_task.category_names.nil? or @parse_task.page_urls.nil?
				format.html { redirect_to parse_tasks_url, alert: "Cant parse, because parse task #{@parse_task.name} dont have categories." }
			else
				format.html { redirect_to parse_tasks_url, notice: "Parse task #{@parse_task.name} was successfully added to queue." }
				ParseJob.perform_later(@parse_task)
			end
		end
	end

	private

	def set_parse_task
		@parse_task = ParseTask.find(params[:id])
	end

	def set_task_info
		@name = params[:parse_task][:name]
		@web_site = params[:web_site].to_i
		puts @web_site
	end

	def check_running_job
		return ParseTask.find_by(status: 2) != nil
	end

	def parse_task_params
		params.require(:parse_task).permit(:name, :web_site)
	end
end
