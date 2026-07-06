class AddCapacityOverridesToGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :groups, :max_group_size, :integer
    add_column :groups, :max_overbooking, :integer
  end
end
