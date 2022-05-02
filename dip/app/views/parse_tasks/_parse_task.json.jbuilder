json.extract! parse_task, :id, :name, :web_site, :status, :category_names, :page_urls, :finish_date, :created_at, :updated_at
json.url parse_task_url(parse_task, format: :json)
