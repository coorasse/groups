class RemoveNameAndCountsFromGroups < ActiveRecord::Migration[8.1]
  def change
    remove_column :groups, :name, :string, null: false
    remove_column :groups, :adults_count, :integer, null: false, default: 0
    remove_column :groups, :kids_count, :integer, null: false, default: 0
  end
end
