class CreateLeonardoProducts < ActiveRecord::Migration[7.0]
	def change
		create_table :leonardo_products do |t|
			t.string :name
			t.string :brend
			t.float :price
			t.string :img
			t.boolean :instock
			t.float :rating
			t.integer :evaluators
			t.string :desc

			t.timestamps
		end
	end
end
