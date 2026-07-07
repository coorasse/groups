class AddNotifiedToReservations < ActiveRecord::Migration[8.1]
  def change
    add_column :reservations, :notified, :boolean, null: false, default: false
  end
end
