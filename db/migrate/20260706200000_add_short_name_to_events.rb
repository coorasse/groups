class AddShortNameToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :short_name, :string
  end
end
