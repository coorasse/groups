class EnforceMinimumOverbooking < ActiveRecord::Migration[8.1]
  # Every group must keep an overbooking allowance of at least 1, so existing
  # zeroes are bumped and the event default is raised accordingly.
  def up
    Event.where(max_overbooking: 0).update_all(max_overbooking: 1)
    Group.where(max_overbooking: 0).update_all(max_overbooking: 1)
    change_column_default :events, :max_overbooking, from: 0, to: 1
  end

  def down
    change_column_default :events, :max_overbooking, from: 1, to: 0
  end
end
