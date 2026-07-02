class AddDetailsToGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :groups, :date, :date
    add_column :groups, :time, :time
    add_column :groups, :status, :integer, null: false, default: 0
    add_column :groups, :notes, :text
  end
end
