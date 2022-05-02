class ParseTasksController < ApplicationController
  before_action :set_parse_task, only: %i[ show edit update destroy parse ]
  before_action :set_task_info, only: %i[ create update ]

  # GET /parse_tasks or /parse_tasks.json
  def index
    @parse_tasks = ParseTask.all
  end

  # GET /parse_tasks/1 or /parse_tasks/1.json
  def show
  end

  # GET /parse_tasks/new
  def new
    @parse_task = ParseTask.new
  end

# GET /parse_tasks/1/edit
	def edit
		if @parse_task.status != 1
			redirect_to parse_tasks_urlm, alert: "Parse task is in progress or finished."
		end
	end

  # POST /parse_tasks or /parse_tasks.json
	def create
		@parse_task = ParseTask.new(name: @name, web_site: @web_site, status: @status, category_names: @category_names, page_urls: @page_urls)

		respond_to do |format|
			if @parse_task.save
				format.html { redirect_to parse_task_url(@parse_task), notice: "Parse task was successfully created." }
#			format.json { render :show, status: :created, location: @parse_task }
			else
				format.html { render :new, status: :unprocessable_entity }
#			format.json { render json: @parse_task.errors, status: :unprocessable_entity }
			end
		end
	end

# PATCH/PUT /parse_tasks/1 or /parse_tasks/1.json
	def update
		respond_to do |format|
			if @parse_task.update(name: @name, web_site: @web_site, status: @status, category_names: @category_names, page_urls: @page_urls)
				format.html { redirect_to parse_task_url(@parse_task), notice: "Parse task was successfully updated." }
#				format.json { render :show, status: :ok, location: @parse_task }
			else
				format.html { render :edit, status: :unprocessable_entity }
#				format.json { render json: @parse_task.errors, status: :unprocessable_entity }
			end
		end
	end

# DELETE /parse_tasks/1 or /parse_tasks/1.json
	def destroy
		if @parse_task.status != 2
			@parse_task.destroy

			respond_to do |format|
				format.html { redirect_to parse_tasks_url, notice: "Parse task was successfully destroyed." }
#			format.json { head :no_content }
			end
		else
			redirect_to parse_tasks_urlm, alert: "Cant delete, because parse task is in progress."
		end
	end

	def parse
		if @parse_task.update(status: 2)
			redirect_to parse_task_url(@parse_task), notice: "Parse task was successfully added to queue." 
			LitresBookParseJob.perform_later(@parse_task.page_urls, @parse_task)
		else 
			redirect_to parse_task_url(@parse_task), alert: "Parse failed." 
		end
	end

	private
# Use callbacks to share common setup or constraints between actions.
	def set_parse_task
		@parse_task = ParseTask.find(params[:id])
	end

	def set_task_info
		@name = params[:parse_task][:name]
		@web_site = params[:parse_task][:web_site].to_i
		@status = params[:parse_task][:status].to_i
		@category_names = []
		@page_urls = []
		if @web_site == 1
			if params[:parse_task][:classic] == "1"
				@category_names.push("Classic")
				@page_urls.push("https://www.litres.ru/klassicheskaya-literatura/")
			end
			if params[:parse_task][:fantasy] == "1"
				@category_names.push("Fantasy")
				@page_urls.push("https://www.litres.ru/knigi-fentezi/")
			end
			if params[:parse_task][:detective] == "1"
				@category_names.push("Detective")
				@page_urls.push("https://www.litres.ru/knigi-detektivy/")
			end
		end
	end

    # Only allow a list of trusted parameters through.
    def parse_task_params
      params.require(:parse_task).permit(:name, :web_site, :status)
    end
end