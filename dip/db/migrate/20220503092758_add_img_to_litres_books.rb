class AddImgToLitresBooks < ActiveRecord::Migration[7.0]
  def change
    add_column :litres_books, :img, :string
  end
end
