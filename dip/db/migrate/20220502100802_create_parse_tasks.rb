class CreateParseTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :parse_tasks do |t|
      t.string :name
      t.integer :web_site
      t.integer :status
      t.string :category_names, array: true
      t.string :page_urls, array: true
      t.date :finish_date, default: nil

      t.timestamps
    end
  end
end
