class AddNotifyDaysBeforeToEventsAndGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :notify_days_before, :integer, null: false, default: 2
    add_column :groups, :notify_days_before, :integer
  end
end
