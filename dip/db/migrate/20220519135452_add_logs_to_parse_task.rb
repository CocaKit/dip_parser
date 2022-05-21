class AddLogsToParseTask < ActiveRecord::Migration[7.0]
  def change
    add_column :parse_tasks, :logs, :text
  end
end
