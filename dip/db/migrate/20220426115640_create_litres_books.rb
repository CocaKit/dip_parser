class CreateLitresBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :litres_books do |t|
      t.string :main_genre
      t.string :name
      t.string :author
      t.string :series
      t.float :grade_litres
      t.float :grade_livelib
      t.integer :evaluators_litres
      t.integer :evaluators_livelib
      t.string :genres, array: true
      t.string :tags, array: true
      t.integer :age_limit
      t.integer :release_on_website
      t.integer :release_on_world
      t.integer :release_translate
      t.integer :book_size
	  t.string :isbn
      t.float :price
      t.text :description
      t.string :page_url

      t.timestamps
    end
	add_index :litres_books, :name
  end
end
