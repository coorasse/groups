class AddMaxOverbookingToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :max_overbooking, :integer, null: false, default: 0
  end
end
