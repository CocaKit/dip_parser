class AddSourceUrlToLeonardoProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :leonardo_products, :source_url, :string
  end
end
