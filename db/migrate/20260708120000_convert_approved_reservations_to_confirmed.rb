class ConvertApprovedReservationsToConfirmed < ActiveRecord::Migration[8.1]
  # The "approved" state (integer 1) is dropped: the approval phase no longer
  # exists and those reservations are effectively confirmed.
  def up
    Reservation.where(status: 1).update_all(status: 2)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
