class AddCategoryNameToLeonardoProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :leonardo_products, :category_name, :string
  end
end
